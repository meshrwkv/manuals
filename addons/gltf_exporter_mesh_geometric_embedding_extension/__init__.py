import bpy
from bpy.props import StringProperty, BoolProperty
from bpy_extras.io_utils import ExportHelper

bl_info = {
    "name": "GLTF Mesh Geometric Embedding Writer",
    "author": "K. S. Ernest (iFire) Lee",
    "version": (1, 0),
    "blender": (3, 0, 0),
    "location": "File > Export > glTF 2.0",
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
        description="Geometric Embedding",
        default=True,
    )


class GLTF_PT_MeshGeometricEmbeddingExtensionPanel(bpy.types.Panel):
    bl_space_type = "FILE_BROWSER"
    bl_region_type = "TOOL_PROPS"
    bl_label = "Geometric Embedding Extension"
    bl_parent_id = "GLTF_PT_export_data"
    bl_options = {"DEFAULT_CLOSED"}

    @classmethod
    def poll(cls, context):
        sfile = context.space_data
        operator = sfile.active_operator
        return operator.bl_idname == "EXPORT_SCENE_OT_gltf"

    def draw_header(self, context):
        props = bpy.context.scene.MeshGeometricEmbeddingExtensionProperties
        self.layout.prop(props, "enabled")

    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False  # No animation.

        props = bpy.context.scene.MeshGeometricEmbeddingExtensionProperties
        layout.active = props.enabled


class MeshGeometricEmbeddingExtension:
    def __init__(self):
        from io_scene_gltf2.io.com.gltf2_io_extensions import Extension

        self.Extension = Extension
        self.properties = bpy.context.scene.MeshGeometricEmbeddingExtensionProperties

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
        if not self.properties.enabled:
            return {"FINISHED"}

        if gltf2_mesh.extensions is None:
            gltf2_mesh.extensions = {}
        gltf2_mesh.extensions[glTF_extension_name] = self.Extension(
            name=glTF_extension_name,
            extension={"bool": self.properties.enabled},
            required=extension_is_required
        )
        if gltf2_mesh.extensions is None:
            gltf2_mesh.extensions = {}
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

        gltf2_mesh.extensions[glTF_extension_name] = {
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

classes = (
    MeshGeometricEmbeddingExtensionProperties,
    GLTF_PT_MeshGeometricEmbeddingExtensionPanel,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.Scene.MeshGeometricEmbeddingExtensionProperties = (
        bpy.props.PointerProperty(type=MeshGeometricEmbeddingExtensionProperties)
    )


def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
    del bpy.types.Scene.MeshGeometricEmbeddingExtensionProperties


if __name__ == "__main__":
    register()
