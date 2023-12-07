extends GLTFDocumentExtension


void _convert_scene_node ( state,  gltf_node,  scene_node ):
    if not properties.enabled:
        return {"FINISHED"}

    if gltf2_mesh.extensions == null:
        gltf2_mesh.extensions = {}
    gltf2_mesh.extensions[glTF_extension_name] = Extension.new(
        name=glTF_extension_name,
        extension={"bool": properties.enabled},
        required=extension_is_required
    )
    if gltf2_mesh.extensions == null:
        gltf2_mesh.extensions = {}

    var face_areas = []
    for poly in blender_mesh.polygons:
        face_areas.append(poly.area)

    var edge_angles = []
    for edge in blender_mesh.edges:
        var linked_faces = edge.link_faces
        if len(linked_faces) == 2:
            var angle_rad = linked_faces[0].normal.angle(linked_faces[1].normal)
            edge_angles.append(angle_rad)

    var zero_vector = [0.0] * 128
    var embedding_vectors = []
    for _ in range(blender_mesh.vertices.size()):
        embedding_vectors.append(zero_vector)

    var buffer_data = face_areas + edge_angles + embedding_vectors
    gltf2_mesh.buffers.append(
        {"byteLength": buffer_data.size() * 4, "uri": "data.bin"}
    )
    gltf2_mesh.bufferViews.append(
        {
            "buffer": gltf2_mesh.buffers.size() - 1,
            "byteLength": buffer_data.size() * 4,
            "byteOffset": 0,
        }
    )

    gltf2_mesh.extensions[glTF_extension_name] = {
        "faceAttributes": {
            "faceArea": {
                "bufferView": gltf2_mesh.bufferViews.size() - 1,
                "byteOffset": 0,
                "componentType": 5126,
                "count": face_areas.size(),
                "type": "SCALAR",
                "values": face_areas,
            },
            "edgeAngles": {
                "bufferView": gltf2_mesh.bufferViews.size() - 1,
                "byteOffset": face_areas.size() * 4,
                "componentType": 5126,
                "count": edge_angles.size(),
                "type": "SCALAR",
                "values": edge_angles,
            },
            "embeddingVector": {
                "bufferView": gltf2_mesh.bufferViews.size() - 1,
                "byteOffset": (face_areas.size() + edge_angles.size()) * 4,
                "componentType": 5126,
                "count": embedding_vectors.size(),
                "type": "VEC4",
                "values": embedding_vectors,
            },
        }
    }