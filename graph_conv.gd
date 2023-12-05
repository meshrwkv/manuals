extends Node

var conv: GraphConv

func _ready() -> void:
    var in_channels: int = # Define your input channels
    var out_channels: int = # Define your output channels
    conv = GraphConv.new(in_channels, out_channels)

func get_mesh_data(mesh: Mesh) -> Dictionary:
    var tool: MeshDataTool = MeshDataTool.new()
    tool.create_from_surface(mesh, 0)
    
    var vertices: Array = []
    var edges: Array = []
    var normals: Array = []
    var areas: Array = []

    for i in range(tool.get_vertex_count()):
        vertices.append(tool.get_vertex(i))

    for i in range(tool.get_edge_count()):
        edges.append(tool.get_edge_vertices(i))

    for i in range(tool.get_face_count()):
        normals.append(tool.get_face_normal(i))
        areas.append(tool.get_face_area(i))
        
    return {"vertices": vertices, "edges": edges, "normals": normals, "areas": areas}

func forward(data: Dictionary) -> Array:
    var x: Array = data["x"]
    var edge_index: Array = data["edge_index"]

    # Apply graph convolution
    x = conv.forward(x, edge_index)
    
    return x
