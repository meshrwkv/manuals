class_name FaceData

var vertices: Array
var normal: Vector3
var area: float
var angle: float

func _init(_vertices: PackedVector3Array, _normal: Vector3, _area: float, _angle: float) -> void:
    if _vertices.size() > 4 or _vertices.size() < 1:
        print("Only points, lines, triangles or quads are supported")
        return
    match _vertices.size():
        1: # Point
            _vertices.append(_vertices[0]) # Duplicate the point three times
            _vertices.append(_vertices[0])
            _vertices.append(_vertices[0])
        2: # Line
            _vertices.append(_vertices[0]) # Duplicate one of the points twice
            _vertices.append(_vertices[0])
        3: # Triangle
            _vertices.append(_vertices[_vertices.size() - 1]) # Duplicate the last vertex
        4: # Quad
            pass # No need to change anything for quads
    vertices = _vertices
    normal = _normal
    area = _area
    angle = _angle
