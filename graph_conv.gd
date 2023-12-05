# SPDX-License-Identifier: MIT OR Apache-2.0
# Copyright (c) K. S. Ernest (iFire) Lee

extends Node

var conv: SAGEConv
var codebook: Codebook  # Assuming you have a Codebook class for RQ
var decoder: Decoder  # Assuming you have a Decoder class for decoding embeddings


func _ready() -> void:
    var in_channels: int = # Define your input channels
    var out_channels: int = # Define your output channels
    conv = SAGEConv.new(in_channels, out_channels)
    codebook = Codebook.new()  # Initialize your codebook
    decoder = Decoder.new()  # Initialize your decoder


func get_mesh_data(mesh: Mesh) -> Dictionary:
    var tool: MeshDataTool = MeshDataTool.new()
    tool.create_from_surface(mesh, 0)

    var vertices: Array = []
    var edges: Array = []
    var normals: Array = []
    var areas: Array = []
    var angles: Array = []

    for i in range(tool.get_vertex_count()):
        vertices.append(tool.get_vertex(i))

    # Sort vertices in z-y-x order [43] Charlie Nash, Yaroslav Ganin, SM Ali Eslami, and Peter Battaglia. Polygen
    vertices.sort_custom(self, "compare_vertices")

    for i in range(tool.get_edge_count()):
        edges.append(tool.get_edge_vertices(i))

    for i in range(tool.get_face_count()):
        normals.append(tool.get_face_normal(i))
        areas.append(tool.get_face_area(i))

        # Calculate angles between edges
        var face_vertices: Array = tool.get_face_vertices(i)
        var angle: float = face_vertices[0].angle_to(face_vertices[1])
        angles.append(angle)

    # Order faces based on their lowest vertex index
    var faces: Array = []
    for i in range(tool.get_face_count()):
        var face_vertices: Array = tool.get_face_vertices(i)
        face_vertices.sort()
        faces.append(face_vertices)

    return {"vertices": vertices, "edges": edges, "normals": normals, "areas": areas, "faces": faces, "angles": angles}


func compare_vertices(a: Vector3, b: Vector3) -> int:
    if a.z != b.z:
        return a.z < b.z ? -1 : 1
    elif a.y != b.y:
        return a.y < b.y ? -1 : 1
    else:
        return a.x < b.x ? -1 : 1


func forward(data: Dictionary) -> Array:
    var x: Array = data["x"]
    var edge_index: Array = data["edge_index"]

    # Apply SAGEConv
    x = conv.forward(x, edge_index)

    # Perform RQ and get tokens
    var tokens: Array = codebook.quantize(x)

    # Decode the quantized embeddings
    var reconstructed_mesh: Mesh = decoder.decode(tokens)

    return reconstructed_mesh


## Citations

# [43] Charlie Nash, Yaroslav Ganin, SM Ali Eslami, and Peter
# Battaglia. Polygen: An autoregressive generative model of
# 3d meshes. In International conference on machine learning,
# pages 7220–7229. PMLR, 2020