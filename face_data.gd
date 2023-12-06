class_name FaceData

var vertices: PackedVector3Array
var normal: Vector3
var area: float
var angle: float

func _init(_vertices: PackedVector3Array, _normal: Vector3, _area: float, _angle: float) -> void:
    if _vertices.size() != 3:
        print("Only triangles are supported")
        return
    vertices = _vertices
    normal = _normal
    area = _area
    angle = _angle
