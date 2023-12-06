class_name FaceData

var vertices: Array
var normal: Vector3
var area: float
var angle: float

func _init(_vertices: PackedVector3Array, _normal: Vector3, _area: float, _angle: float) -> void:
    if _vertices.size() not in [3, 4]:
        print("Only triangles or quads are supported")
        return
    if _vertices.size() == 3:
        _vertices.append(_vertices[_vertices.size() - 1])
    vertices = _vertices
    normal = _normal
    area = _area
    angle = _angle
