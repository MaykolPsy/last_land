extends Node3D
class_name ItemSpawner

@export var items: Array[PackedScene]
@export var player_path: NodePath

@export_group("Spawn Timing")
@export var start_delay: float = 1.5
@export var spawn_interval: float = 3.0

@export_group("Spawn Position")
@export var min_spawn_ahead: float = 120.0
@export var max_spawn_ahead: float = 180.0
@export var spawn_height: float = 2.0
@export var x_min: float = -120.0
@export var x_max: float = 120.0

# CLAVE: si tu barco avanza en -Z, pon -1.0
# si avanza en +Z, pon 1.0
@export var forward_sign_z: float = 1.0

var player: Node3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_try_get_player()
	call_deferred("_spawn_loop")

func _try_get_player() -> void:
	if player == null or not is_instance_valid(player):
		player = get_node_or_null(player_path) as Node3D

func _spawn_loop() -> void:
	await get_tree().create_timer(start_delay, true).timeout

	while is_inside_tree():
		await get_tree().create_timer(spawn_interval, true).timeout
		_try_get_player()
		_spawn_one_item()

func _spawn_one_item() -> void:
	if player == null or items.is_empty():
		return

	var ahead_z := randf_range(min_spawn_ahead, max_spawn_ahead) * forward_sign_z
	var x := randf_range(x_min, x_max)

	var spawn_pos := Vector3(
		x,
		player.global_position.y + spawn_height,
		player.global_position.z + ahead_z
	)

	var item := items.pick_random().instantiate() as Node3D
	if item == null:
		return

	var scene := get_tree().current_scene
	if scene == null:
		return

	scene.add_child(item)
	item.global_position = spawn_pos
	item.scale = Vector3.ONE
