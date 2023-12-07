import bpy
import json

bl_info = {
    "name": "GLTF Data Writer",
    "author": "Your Name",
    "version": (1, 0),
    "blender": (2, 80, 0),
    "location": "View3D > Tool > GLTF Data Writer",
    "description": "Writes GLTF data with VSEKAI_mesh_geometric_embedding set to all zeros",
    "warning": "",
    "wiki_url": "",
    "category": "Development",
}


class GLTFDataWriter(bpy.types.Operator):
    """GLTF Data Writer"""

    bl_idname = "object.gltf_data_writer"
    bl_label = "Write GLTF Data"
    bl_options = {"REGISTER", "UNDO"}

    def execute(self, context):
        # Initialize a 128-dimensional zero vector for embedding
        zero_vector = [0.0] * 128

        data = {
            "asset": {"version": "2.0"},
            "extensionsUsed": [
                "EXT_structural_metadata",
                "VSEKAI_mesh_geometric_embedding",
            ],
            "extensions": {
                "VSEKAI_mesh_geometric_embedding": {},
                "EXT_structural_metadata": {
                    "faceAttributes": {
                        "faceArea": {
                            "bufferView": 1,
                            "byteOffset": 0,
                            "componentType": 5126,
                            "count": 4,
                            "type": "SCALAR",
                        },
                        "edgeAngles": {
                            "bufferView": 2,
                            "byteOffset": 0,
                            "componentType": 5126,
                            "count": 12,
                            "type": "VEC3",
                        },
                        "embeddingVector": {
                            "bufferView": 3,
                            "byteOffset": 0,
                            "componentType": 5126,
                            "count": len(zero_vector),
                            "type": "VEC4",
                            "values": zero_vector,
                        },
                    },
                    "faceMappings": [
                        {"index": 0, "values": [0, 1, 2]},
                        {"index": 1, "values": [3, 4, 5]},
                        {"index": 2, "values": [6, 7, 8]},
                        {"index": 3, "values": [9, 10, 11]},
                    ],
                },
            },
            # Rest of your GLTF data goes here
        }

        with open("gltf_data.json", "w") as f:
            json.dump(data, f, indent=4)

        return {"FINISHED"}


def menu_func(self, context):
    self.layout.operator(GLTFDataWriter.bl_idname)


def register():
    bpy.utils.register_class(GLTFDataWriter)
    bpy.types.VIEW3D_MT_object.append(menu_func)


def unregister():
    bpy.utils.unregister_class(GLTFDataWriter)
    bpy.types.VIEW3D_MT_object.remove(menu_func)


if __name__ == "__main__":
    register()
