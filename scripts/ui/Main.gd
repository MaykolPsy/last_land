extends Node3D

@onready var boat_pivot: Node3D = $BoatPivot
@onready var ocean_root: Node3D = $OceanChunk
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var sky_controller: SkyController = $SkyController

@export var storm_build_time: float = 30.0
@export var auto_rotate_boat_in_menu: bool = true

var ocean_mesh: MeshInstance3D = null
var start_requested: bool = false

func _ready() -> void:
	if sky_controller:
		sky_controller.auto_progress = true
		sky_controller.seconds_to_full_storm = storm_build_time
		sky_controller.set_progress(0.0)

	_setup_light()
	_setup_ocean_existing_material()

func _process(delta: float) -> void:
	if auto_rotate_boat_in_menu and not start_requested and boat_pivot:
		boat_pivot.rotation.y += 0.15 * delta

# Esto lo puedes llamar desde Menu.gd (signal) o botón
func start_game() -> void:
	start_requested = true
	if boat_pivot:
		var tw := create_tween()
		tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(boat_pivot, "rotation:y", boat_pivot.rotation.y + PI * 0.5, 0.6)

func _setup_light() -> void:
	if sun == null:
		return
	sun.light_energy = 1.6
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.shadow_enabled = false
	sun.rotation_degrees = Vector3(-35.0, 35.0, 0.0)

func _setup_ocean_existing_material() -> void:
	if ocean_root == null:
		return

	ocean_mesh = _find_first_mesh_instance(ocean_root)
	if ocean_mesh == null:
		push_warning("OceanChunk no tiene MeshInstance3D hijo.")
		return

	ocean_root.position.y = -0.25

	if ocean_mesh.mesh == null:
		var plane := PlaneMesh.new()
		plane.size = Vector2(250.0, 250.0)
		ocean_mesh.mesh = plane
	elif ocean_mesh.mesh is PlaneMesh:
		(ocean_mesh.mesh as PlaneMesh).size = Vector2(250.0, 250.0)

	if ocean_mesh.material_override is ShaderMaterial:
		return
	if ocean_mesh.get_active_material(0) is ShaderMaterial:
		return

	push_warning("El mesh dentro de OceanChunk no tiene ShaderMaterial (override/surface0).")

func _find_first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child in node.get_children():
		var found := _find_first_mesh_instance(child)
		if found != null:
			return found
	return null
