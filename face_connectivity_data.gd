class_name ConnectivityData
var faces: Array
var adjacency_matrix: Array

func _init(_faces: Array):
    faces = _faces
    adjacency_matrix = calculate_adjacency_matrix()

func calculate_adjacency_matrix() -> Array:
    var num_faces := faces.size()
    var adjacency_matrix := []
    for i in range(num_faces):
        for j in range(num_faces):
            if i != j and faces[i].vertices.intersect(faces[j].vertices).size() > 0:
                adjacency_matrix.append([i, j, 1])
    return adjacency_matrix
