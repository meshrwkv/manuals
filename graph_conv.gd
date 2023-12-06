# SPDX-License-Identifier: MIT OR Apache-2.0
# Copyright (c) K. S. Ernest (iFire) Lee

extends Node

var conv: SAGEConv
var codebook: Codebook  # Assuming you have a Codebook class for RQ
var decoder: Decoder  # Assuming you have a Decoder class for decoding embeddings

func compare_faces(pair_a: Array, pair_b: Array) -> int:
        var a = pair_a[1]
        var b = pair_b[1]
        if a.area != b.area:
            return -1 if a.area < b.area else 1
        elif a.angle != b.angle:
            return -1 if a.angle < b.angle else 1
        elif a.normal != b.normal:
            return -1 if a.normal < b.normal else 1
        else:
            return compare_vertices(a.vertices, b.vertices)

func compare_vertices(a: list, b: list) -> int:
        for i in range(len(a)):
            if a[i].z != b[i].z:
                return -1 if a[i].z < b[i].z else 1
            elif a[i].y != b[i].y:
                return -1 if a[i].y < b[i].y else 1
            elif a[i].x != b[i].x:
                return -1 if a[i].x < b[i].x else 1
        return 0

func _ready() -> void:
    var in_channels: int = # Define your input channels
    var out_channels: int = # Define your output channels
    conv = SAGEConv.new(in_channels, out_channels)
    codebook = Codebook.new()  # Initialize your codebook
    decoder = Decoder.new()  # Initialize your decoder

    var mesh_data: Dictionary = get_mesh_data(ArrayMesh.new())

    var original_mesh_faces = mesh_data["faces"]
    # Create an array of pairs (index, face)
    var index_face_pairs = []
    for i in range(original_mesh_faces.size()):
        index_face_pairs.append([i, original_mesh_faces[i]])

    # Sort the index_face_pairs array using a custom comparison function
    index_face_pairs.sort_custom(self, "compare_faces")

    # Reorder the 'faces' and 'adjacency_matrix' arrays
    var sorted_faces = []
    var sorted_adjacency_matrix = []
    for pair_i in range(index_face_pairs.size()):
        var pair: Array = index_face_pairs[pair_i]
        sorted_faces.append(pair[1])
        sorted_adjacency_matrix.append(mesh_data["adjacency_matrix"][pair[0]])

    # Apply SAGEConv
    x = conv.forward(sorted_faces, sorted_adjacency_matrix)

    # Perform RQ and get tokens
    var tokens: Array = codebook.quantize(x)

    # Decode the quantized embeddings
    var reconstructed_mesh: Mesh = decoder.decode(tokens)

    return reconstructed_mesh

# {
#     "faces": [
#         {
#             "vertices": [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)],
#             "data": FaceData([Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0)], Vector3(0, 0, 1), 0.5, [1.5708, 0, 0])
#         },
#         {
#             "vertices": [Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)],
#             "data": FaceData([Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)], Vector3(-1, 0, 0), 0.5, [1.5708, 0, 0])
#         },
#         {
#             "vertices": [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)],
#             "data": FaceData([Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)], Vector3(0, -1, 0), 0.5, [1.5708, 0, 0])
#         },
#         {
#             "vertices": [Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)],
#             "data": FaceData([Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1)], Vector3(1/3, 1/3, 1/3), 0.5, [1.5708, 0, 0])
#         }
#     ],
#     "adjacency_matrix": [
#         [0, 1, 1, 1],
#         [1, 0, 1, 1],
#         [1, 1, 0, 1],
#         [1, 1, 1, 0]
#     ]
# }
func get_mesh_data(mesh: Mesh) -> Dictionary:
    var tool: MeshDataTool = MeshDataTool.new()
    tool.create_from_surface(mesh, 0)

    var faces: Array = []
    for i in range(tool.get_face_count()):
        var vertices: Array = []
        for j in range(3):
            vertices.append(tool.get_vertex(tool.get_face_vertex(i, j)))
        var normal: Vector3 = tool.get_face_normal(i)
        var area: float = normal.length() / 2.0

        # Calculate the three angles of the triangle
        var angles: Array = []
        for j in range(3):
            var v1: Vector3 = vertices[j] - vertices[(j+1)%3]
            var v2: Vector3 = vertices[j] - vertices[(j+2)%3]
            angles.append(v1.angle_to(v2))

        faces.append({
            "vertices": vertices,
            "data": FaceData.new(vertices, normal, area, angles)
        })

    var face_data_array: Array = []
    for face in faces:
        face_data_array.append(face["data"])

    var connectivity_data: ConnectivityData = ConnectivityData.new(face_data_array)

    return {
        "faces": faces,
        "adjacency_matrix": connectivity_data.get_adjacency_matrix()
    }


## Citations

# [43] Charlie Nash, Yaroslav Ganin, SM Ali Eslami, and Peter
# Battaglia. Polygen: An autoregressive generative model of
# 3d meshes. In International conference on machine learning,
# pages 7220–7229. PMLR, 2020