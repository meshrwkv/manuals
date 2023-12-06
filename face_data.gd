class_name FaceData
var vertices: Array
var normal: Vector3
var area: float
var angle: float

func _init(_vertices: Array, _normal: Vector3, _area: float, _angle: float):
    vertices = _vertices
    normal = _normal
    area = _area
    angle = _angle
