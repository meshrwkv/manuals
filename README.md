# VSEKAI_mesh_geometric_embedding GLTF 2.0 Extension Specification

## Contributors

- K. S. Ernest (iFire) Lee, V-Sekai & Godot Engine, [@fire](https://github.com/fire)

## Status

Draft

## Dependencies

Written against the glTF 2.0 specification and the EXT_structural_metadata extension.

## Overview

The `VSEKAI_mesh_geometric_embedding` extension is an extension for the GLTF 2.0 specification. This extension provides additional geometric metadata for meshes, including face area, edge definition, edge area, and edge angles in radians. Each vertex of a face has a 128 float embedding vector.

## Extension Schema

```json
{
  "asset": {
    "version": "2.0"
  },
  "extensionsUsed": [
    "EXT_structural_metadata",
    "VSEKAI_mesh_geometric_embedding"
  ],
  "extensions": {
    "EXT_structural_metadata": {
      "faceAttributes": {
        "face_area": {
          "bufferView": 1,
          "byteOffset": 0,
          "componentType": 5126,
          "count": 4,
          "type": "SCALAR"
        },
        "edge_angles": {
          "bufferView": 2,
          "byteOffset": 0,
          "componentType": 5126,
          "count": 12,
          "type": "VEC3"
        },
        "embedding_vector": {
          "bufferView": 3,
          "byteOffset": 0,
          "componentType": 5126,
          "count": 1536,
          "type": "VEC4"
        }
      },
      "faceMappings": [
        { "index": 0, "values": [0, 1, 2] },
        { "index": 1, "values": [3, 4, 5] },
        { "index": 2, "values": [6, 7, 8] },
        { "index": 3, "values": [9, 10, 11] }
      ]
    }
  },
  "nodes": [
    {
      "mesh": 0
    }
  ],
  "meshes": [
    {
      "primitives": [
        {
          "attributes": {
            "POSITION": 0,
            "NORMAL": 1
          },
          "indices": 2
        }
      ]
    }
  ],
  "buffers": [
    {
      "byteLength": 6144,
      "uri": "external_file.bin"
    }
  ],
  "bufferViews": [
    {
      "buffer": 0,
      "byteOffset": 0,
      "byteLength": 6144
    }
  ],
  "accessors": [
    {
      "bufferView": 0,
      "byteOffset": 0,
      "componentType": 5126,
      "count": 4,
      "type": "VEC3",
      "max": [1.0, 1.0, 1.0],
      "min": [-1.0, -1.0, -1.0]
    },
    {
      "bufferView": 0,
      "byteOffset": 48,
      "componentType": 5126,
      "count": 4,
      "type": "VEC3"
    },
    {
      "bufferView": 0,
      "byteOffset": 96,
      "componentType": 5123,
      "count": 12,
      "type": "SCALAR"
    }
  ]
}
```

## Extension Components

- `faceAttributes`: Contains attributes related to the faces of the mesh. This includes `embedding_vector`.
- `faceMappings`: Maps face index values to their corresponding values in the `faceAttributes`.

## Usage

This extension can be used to provide additional geometric information about a mesh, such as the embedding vector for each face index. The embedding vectors are particularly useful for large language models to parse the GLTF more efficiently.

## Indexed Mesh Requirement

For this extension to function correctly, the mesh must be indexed. An indexed mesh uses an array of indices to reference vertices, allowing for efficient reuse of vertex data and reducing the overall size of the mesh data.

## Normals

Normals are required for each face of the mesh. A face is defined by three vertices. The normal of a face is a vector that is perpendicular to the plane of the face. In the above schema, normals are included in the `attributes` section of each primitive in the `meshes` array. The `NORMAL` attribute is an accessor index that points to the buffer view containing the normal data.

## Vertex and Face Sorting Scheme

The vertex and face sorting scheme is a crucial part of the `VSEKAI_mesh_geometric_embedding` extension. It ensures that the geometric data is organized in a consistent and predictable manner, which is essential for efficient processing and accurate rendering.

Vertices within each face are sorted first. The comparison function `compare_vertices` is used to sort an array of vertices. This function compares two vertices based on their z-coordinate first. If the z-coordinates are equal, it then compares the y-coordinates. If the y-coordinates are also equal, it finally compares the x-coordinates.

After the vertices have been sorted, faces are sorted based on their index ID. The comparison function `compare_faces` is used to sort an array of faces. This function compares two faces based on their index ID.

```gdscript
# Sorting scheme based on:
# [43] Charlie Nash, Yaroslav Ganin, SM Ali Eslami, and Peter Battaglia.
# Polygen: An autoregressive generative model of 3d meshes.
# In International conference on machine learning, pages 7220–7229. PMLR, 2020

func compare_vertices(vertices_a, vertices_b):
    for i in range(len(vertices_a)):
        # Compare vertex positions
        if vertices_a[i].position < vertices_b[i].position:
            return -1
        elif vertices_a[i].position > vertices_b[i].position:
            return 1

    # If all vertex positions are equal, the vertices are equal
    return 0

func compare_faces(pair_a, pair_b):
    a = pair_a[1]
    b = pair_b[1]

    # Compare vertices first
    vertex_comparison = compare_vertices(a.vertices, b.vertices)
    if vertex_comparison != 0:
        return vertex_comparison

    # If vertices are equal, compare face IDs
    if a.id < b.id:
        return -1
    elif a.id > b.id:
        return 1

    return 0
```

## High-dimensional Vector Generation

The embedding vectors are generated using a 1-D ResNet model and GraphSAGE. The model operates on the sorted vertices and faces, taking into account their connections to other faces via the weight of distance and the attributes of position, normals, face area, and edge angles.

This approach is based on the MeshGPT method proposed by Siddiqui et al. (2023) in their paper "MeshGPT: Generating Triangle Meshes with Decoder-Only Transformers". The paper can be found [here](https://nihalsid.github.io/mesh-gpt/).

```bibtex
@article{siddiqui2023meshgpt,
  title={MeshGPT: Generating Triangle Meshes with Decoder-Only Transformers},
  author={Siddiqui, Yawar and Alliegro, Antonio and Artemov, Alexey and Tommasi, Tatiana and Sirigatti, Daniele and Rosov, Vladislav and Dai, Angela and Nie{\ss}ner, Matthias},
  journal={arXiv preprint arXiv:2311.15475},
  year={2023}
}
```

## Face Vertex Encoder

The face vertex encoder is responsible for encoding the vertices and faces of a 3D model into a format that can be processed by the neural network. This involves converting the geometric data into a form that can be handled by the machine learning algorithm.

## Embedding Code Book

The embedding code book is a lookup table that maps each token in the input sequence to a high-dimensional vector. These vectors are learned during training and serve as the initial representations for the tokens.

## Token Decoder

The token decoder takes the output of the transformer and converts it back into a sequence of tokens. This involves mapping each output vector to the closest vector in the embedding code book.
