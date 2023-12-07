import bpy
from bpy.props import StringProperty, BoolProperty
from bpy_extras.io_utils import ExportHelper

bl_info = {
    "name": "GLTF Mesh Geometric Embedding Writer",
    "author": "K. S. Ernest (iFire) Lee",
    "version": (1, 0),
    "blender": (3, 0, 0),
    "location": "File > Export > GLTF Data Writer",
    "description": "Writes GLTF data with VSEKAI_mesh_geometric_embedding",
    "warning": "",
    "wiki_url": "",
    "category": "Development",
}

glTF_extension_name = "VSEKAI_mesh_geometric_embedding"

extension_is_required = False


class MeshGeometricEmbeddingExtensionProperties(bpy.types.PropertyGroup):
    enabled: bpy.props.BoolProperty(
        name=bl_info["name"],
        description="Include this extension in the exported glTF file.",
        default=True,
    )


def menu_func_export(self, context):
    self.layout.operator(ExportGLTFData.bl_idname, text="GLTF Data Writer (.gltf)")


def register():
    bpy.utils.register_class(MeshGeometricEmbeddingExtensionProperties)
    bpy.types.Scene.MeshGeometricEmbeddingExtensionProperties = (
        bpy.props.PointerProperty(type=MeshGeometricEmbeddingExtensionProperties)
    )


def unregister():
    bpy.utils.unregister_class(MeshGeometricEmbeddingExtensionProperties)
    del bpy.types.Scene.MeshGeometricEmbeddingExtensionProperties


class ExportGLTFData(bpy.types.Operator, ExportHelper):
    """GLTF Data Writer"""

    bl_idname = "export_scene.gltf_mesh_geometric_embedding"
    bl_label = "Export GLTF Geometric Embedding Data"


    def __init__(self):
        from io_scene_gltf2.io.com.gltf2_io_extensions import Extension

        self.Extension = Extension
        self.properties = bpy.context.scene.MeshGeometricEmbeddingExtensionProperties


    def gather_scene_hook(self, gltf2_scene, blender_scene, export_settings):
        if "extensionsUsed" not in gltf2_scene:
            gltf2_scene["extensionsUsed"] = []
        if "VSEKAI_mesh_geometric_embedding" not in gltf2_scene["extensionsUsed"]:
            gltf2_scene["extensionsUsed"].append("VSEKAI_mesh_geometric_embedding")

        return {"FINISHED"}


    def gather_mesh_hook(
        self,
        gltf2_mesh,
        blender_mesh,
        blender_object,
        vertex_groups,
        modifiers,
        materials,
        export_settings,
    ):
        face_areas = [poly.area for poly in blender_mesh.polygons]

        edge_angles = []
        for edge in blender_mesh.edges:
            linked_faces = edge.link_faces
            if len(linked_faces) == 2:
                angle_rad = linked_faces[0].normal.angle(linked_faces[1].normal)
                edge_angles.append(angle_rad)

        zero_vector = [0.0] * 128
        embedding_vectors = [zero_vector for _ in blender_mesh.vertices]

        buffer_data = face_areas + edge_angles + embedding_vectors
        gltf2_mesh.buffers.append(
            {"byteLength": len(buffer_data) * 4, "uri": "data.bin"}
        )
        gltf2_mesh.bufferViews.append(
            {
                "buffer": len(gltf2_mesh.buffers) - 1,
                "byteLength": len(buffer_data) * 4,
                "byteOffset": 0,
            }
        )

        gltf2_mesh.extensions["EXT_structural_metadata"] = {
            "faceAttributes": {
                "faceArea": {
                    "bufferView": len(gltf2_mesh.bufferViews) - 1,
                    "byteOffset": 0,
                    "componentType": 5126,
                    "count": len(face_areas),
                    "type": "SCALAR",
                    "values": face_areas,
                },
                "edgeAngles": {
                    "bufferView": len(gltf2_mesh.bufferViews) - 1,
                    "byteOffset": len(face_areas) * 4,
                    "componentType": 5126,
                    "count": len(edge_angles),
                    "type": "SCALAR",
                    "values": edge_angles,
                },
                "embeddingVector": {
                    "bufferView": len(gltf2_mesh.bufferViews) - 1,
                    "byteOffset": (len(face_areas) + len(edge_angles)) * 4,
                    "componentType": 5126,
                    "count": len(embedding_vectors),
                    "type": "VEC4",
                    "values": embedding_vectors,
                },
            }
        }

        return {"FINISHED"}


if __name__ == "__main__":
    register()
