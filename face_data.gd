class_name FaceData
var vertices: Array
var normal: Vector3
var area: float
var angle: float

func _init(_vertices: PackedVector3Array, _normal: Vector3, _area: float, _angle: float):
    if not vertices.size() in [3, 4]:
        print("Only triangles or quads are supported")
        return
    vertices = _vertices
    normal = _normal
    area = _area
    angle = _angle
