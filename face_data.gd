class_name FaceData

var vertices: PackedVector3Array
var normal: Vector3
var area: float
var angles: PackedFloat32Array

func _init(_vertices: PackedVector3Array, _normal: Vector3, _area: float, _angles: PackedFloat32Array) -> void:
    if _vertices.size() != 3:
        print("Only triangles are supported")
        return
    if _angles.size() != 3:
        print("Three angles are required for a triangle")
        return
    vertices = _vertices
    normal = _normal
    area = _area
    angles = _angles
