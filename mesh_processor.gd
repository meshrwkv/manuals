class_name MeshProcessor

var triangle_vocabulary: Dictionary = {}
var reverse_vocabulary: Dictionary = {}

func _init(triangles: Array) -> void:
	build_vocabulary(triangles)
	build_reverse_vocabulary()

func build_vocabulary(triangles: Array) -> void:
	var aggregated_features: Dictionary = aggregate_vertex_features(triangles)
	var quantized_positions: Dictionary = quantize_vertex_positions(aggregated_features)
	for triangle: Dictionary in triangles:
		var vertex_features: Array = extract_vertex_features(triangle)
		for i: int in range(vertex_features.size()):
			vertex_features[i] = quantized_positions[vertex_features[i]]
		var graph_conv_features: Array = graph_conv(vertex_features)
		var encoded: int = residual_quantization(graph_conv_features)
		triangle_vocabulary[triangle] = encoded

func build_reverse_vocabulary() -> void:
	for key: Dictionary in triangle_vocabulary.keys():
		reverse_vocabulary[triangle_vocabulary[key]] = key

func extract_vertex_features(triangle: Dictionary) -> Array:
	return [] 

func graph_conv(features: Array) -> Array:
	return []  

func residual_quantization(features: Array) -> int:
	return 0 

func get_encoded_vocabulary() -> Dictionary:
	return triangle_vocabulary

func get_decoded_vocabulary() -> Dictionary:
	return reverse_vocabulary

func update_triangle_vocabulary(triangle: Dictionary, encoded: int) -> void:
	triangle_vocabulary[triangle] = encoded

func remove_from_triangle_vocabulary(triangle: Dictionary) -> void:
	triangle_vocabulary.erase(triangle)

func update_reverse_vocabulary(encoded: int, triangle: Dictionary) -> void:
	reverse_vocabulary[encoded] = triangle

func remove_from_reverse_vocabulary(encoded: int) -> void:
	reverse_vocabulary.erase(encoded)

func aggregate_vertex_features(triangles: Array) -> Dictionary:
	var aggregated_features: Dictionary = {}
	for triangle: Dictionary in triangles:
		var vertex_features: Array = extract_vertex_features(triangle)
		for vertex_index: int in triangle.keys():
			if vertex_index in aggregated_features:
				aggregated_features[vertex_index].append(vertex_features[vertex_index])
			else:
				aggregated_features[vertex_index] = [vertex_features[vertex_index]]
	return aggregated_features

func quantize_vertex_positions(aggregated_features: Dictionary) -> Dictionary:
	var quantized_positions: Dictionary = {}
	for vertex_index: int in aggregated_features.keys():
		var position: Array = aggregated_features[vertex_index]
		var quantized_position: Array = [round(position[0] * 128), round(position[1] * 128), round(position[2] * 128)]
		quantized_positions[vertex_index] = quantized_position
	return quantized_positions
