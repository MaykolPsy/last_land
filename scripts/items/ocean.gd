extends Node3D
class_name OceanChunkController

@export var mesh_path: NodePath = NodePath("MeshInstance3D")

@export_group("Ocean Look")
@export var out_color: Color = Color(0.287, 0.557, 0.548, 1.0)
@export_range(0.05, 1.0, 0.01) var amount: float = 0.4
@export_range(0.0, 10.0, 0.1) var beer_factor: float = 0.2
@export_range(0.0, 1.0, 0.01) var alpha: float = 0.55

@export_group("Surface")
@export_range(0.0, 1.0, 0.01) var metallic: float = 0.3
@export_range(0.0, 1.0, 0.01) var specular: float = 0.15
@export_range(0.0, 1.0, 0.01) var roughness: float = 0.35

var ocean_mesh: MeshInstance3D
var mat: ShaderMaterial

func _ready() -> void:
	_bind()
	_apply_to_shader()

func _process(_delta: float) -> void:
	# si cambias en runtime, se refleja
	_apply_to_shader()

func _bind() -> void:
	ocean_mesh = get_node_or_null(mesh_path) as MeshInstance3D
	if ocean_mesh == null:
		push_warning("OceanChunkController: no se encontró MeshInstance3D en mesh_path.")
		return

	if ocean_mesh.material_override is ShaderMaterial:
		mat = ocean_mesh.material_override as ShaderMaterial
	elif ocean_mesh.get_active_material(0) is ShaderMaterial:
		mat = ocean_mesh.get_active_material(0) as ShaderMaterial
	else:
		push_warning("OceanChunkController: el mesh no tiene ShaderMaterial.")
		return

func _apply_to_shader() -> void:
	if mat == null:
		return

	mat.set_shader_parameter("out_color", out_color)
	mat.set_shader_parameter("amount", amount)
	mat.set_shader_parameter("beer_factor", beer_factor)
	mat.set_shader_parameter("alpha", alpha)

	# agrega estos uniforms en shader (abajo te digo)
	mat.set_shader_parameter("u_metallic", metallic)
	mat.set_shader_parameter("u_specular", specular)
	mat.set_shader_parameter("u_roughness", roughness)
