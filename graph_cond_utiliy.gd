extends Node

# Define variables
var nodes = []
var COO_matrix = []

# This function sums all the Ci for a given node Xi
func sum_Ci_for_node(Xi):
    var sum = 0
    for i in range(len(COO_matrix)):
        if COO_matrix[i][0] == Xi or COO_matrix[i][1] == Xi:
            sum += COO_matrix[i][2]
    return sum

# This function finds the index of a node in the nodes list
func find_node_index(node):
    for i in range(len(nodes)):
        if nodes[i] == node:
            return i
    return -1

# This function implements adjacency matrix
func adjacency_matrix():
    var adj_matrix = []
    for i in range(len(nodes)):
        var row = []
        for j in range(len(nodes)):
            if [nodes[i], nodes[j]] in COO_matrix or [nodes[j], nodes[i]] in COO_matrix:
                row.append(1)
            else:
                row.append(0)
        adj_matrix.append(row)
    return adj_matrix
