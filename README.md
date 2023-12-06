# Readme

## Graph Convolutional Network (GCN) with ResNet34 and COO Sparse Matrix Format

You're discussing the implementation of a **Graph Convolutional Network (GCN)** using **ResNet34** for geometric data. You're also considering the use of **COO (Coordinate List) sparse matrix format** for adjacency representation.

Here's a simplified explanation of your discussion:

### 1. Graph Convolutional Network (GCN)

A GCN is a type of neural network that operates directly on graphs. It uses the graph structure and the nodes' features to generate embeddings for the nodes. These embeddings are then used for tasks such as node classification, link prediction, etc.

### 2. ResNet34

This is a variant of the ResNet (Residual Network) architecture with 34 layers. It's widely used in deep learning for image classification tasks due to its ability to train deep networks by using skip connections or shortcuts to jump over some layers.

### 3. COO Sparse Matrix Format

The COO format is a simple format for representing sparse matrices. In this format, a matrix is represented as a list of (row, column, value) tuples. Only the non-zero values are stored, which makes it efficient for storing large sparse matrices.

### 4. Adjacency Matrix

An adjacency matrix is a square matrix used to represent a finite graph. The elements of the matrix indicate whether pairs of vertices are adjacent or not in the graph.

## Implementation

You're trying to implement a GCN using ResNet34 on geometric data. Each node in your graph represents a polygon with certain attributes (x, y, z coordinates, area, normal, angle). You're considering using a COO sparse matrix to represent the adjacency between these nodes.

### 1. Sequence Generation

This is a type of problem in machine learning where the goal is to generate a sequence of outputs based on a sequence of inputs. In your case, the input is a sequence of geometric embeddings (polygons), and the output is another sequence of geometric embeddings.

### 2. Geometric Embeddings

These are representations of geometric data (in your case, polygons) in a high-dimensional space. The purpose of these embeddings is to capture the essential characteristics of the geometric data in a way that can be processed by machine learning algorithms.

### 3. Polygons

In your context, each polygon is represented as a node in a graph, with certain attributes (x, y, z coordinates, area, normal, angle).

To implement this, you could use an architecture similar to a **Sequence-to-Sequence (Seq2Seq) model**, which is commonly used for tasks like machine translation, where an input sequence (source language sentence) is transformed into an output sequence (target language sentence).
