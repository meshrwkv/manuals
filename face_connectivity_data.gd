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
        for j in range(i+1, num_faces): # Avoid duplicate checks and self-checks
            var shared_vertices = intersect_arrays(faces[i].vertices, faces[j].vertices)
            if shared_vertices.size() >= 2: # Two shared vertices means a shared edge
                adjacency_matrix.append([i, j, 1])
    return adjacency_matrix

func intersect_arrays(a: Array, b: Array) -> Array:
    var result := []
    for element in a:
        if element in b:
            result.append(element)
    return result
