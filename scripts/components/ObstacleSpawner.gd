extends Node
class_name ObstacleSpawner

@export var player_path: NodePath
@export var world_streamer_path: NodePath
@export var obstacles_root_path: NodePath

@export var spawn_distance_ahead := 1200.0
@export var min_spawn_ahead: float = 120.0
@export var min_spacing := 15.0
@export var max_spacing := 60.0
@export_range(0.0, 1.0) var density := 1.0
@export var level_length := 2000.0
@export var obstacle_scenes: Array[PackedScene]

@export var random_y_rotation := true
@export var y_rotation_step_deg := 90.0
@export var tilt_max_deg := 0.0

var level := 1
var player: Node3D
var world_streamer: WorldStreamer
var obstacles_root: Node

var active_obstacles: Array[Node3D] = []
var furthest_spawn_z := 0.0
var spawned_count: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

	player = get_node_or_null(player_path) as Node3D
	world_streamer = get_node_or_null(world_streamer_path) as WorldStreamer
	obstacles_root = get_node_or_null(obstacles_root_path)
	if obstacles_root == null:
		obstacles_root = get_parent()

	if player == null or world_streamer == null:
		push_error("ObstacleSpawner: referencias faltantes")
		return

	furthest_spawn_z = player.global_position.z + min_spawn_ahead
	call_deferred("_initial_spawn")

func can_spawn_at(z_pos: float) -> bool:
	return z_pos >= player.global_position.z + min_spawn_ahead

func _initial_spawn():
	await get_tree().process_frame
	for _i in range(25):
		_spawn_if_needed()

func _process(_delta):
	_update_level()
	_update_difficulty()
	_spawn_if_needed()
	_cleanup_obstacles()

	if Engine.get_process_frames() % 60 == 0:
		print("[ObstacleSpawner] active=", active_obstacles.size(), " spawned_total=", spawned_count)

func _update_level():
	level = int(player.global_position.z / level_length) + 1

func _update_difficulty():
	density = clamp(0.8 + (level * 0.05), 0.5, 0.95)
	min_spacing = max(10.0, 40.0 - level * 2.0)
	max_spacing = max(25.0, 70.0 - level * 3.0)

func _spawn_if_needed():
	var base_z = player.global_position.z
	while furthest_spawn_z < base_z + spawn_distance_ahead:
		furthest_spawn_z = max(furthest_spawn_z, player.global_position.z + min_spawn_ahead)

		if randf() <= density and can_spawn_at(furthest_spawn_z):
			_spawn_obstacle()

		furthest_spawn_z += randf_range(min_spacing, max_spacing)

func _spawn_obstacle():
	var lanes = world_streamer.get_lanes()
	if lanes.is_empty() or obstacle_scenes.is_empty():
		return

	var scene := obstacle_scenes[randi() % obstacle_scenes.size()]
	var obj := scene.instantiate() as Node3D
	if obj == null:
		return

	obstacles_root.add_child(obj)

	var x = lanes[randi() % lanes.size()]
	obj.global_position = Vector3(x, 0.0, furthest_spawn_z)

	if random_y_rotation:
		if y_rotation_step_deg > 0.0:
			var steps: int = int(360.0 / y_rotation_step_deg)
			var step_i: int = randi() % maxi(1, steps)
			obj.rotation_degrees.y = step_i * y_rotation_step_deg
		else:
			obj.rotation_degrees.y = randf_range(0.0, 360.0)

	if tilt_max_deg > 0.0:
		obj.rotation_degrees.x = randf_range(-tilt_max_deg, tilt_max_deg)
		obj.rotation_degrees.z = randf_range(-tilt_max_deg, tilt_max_deg)

	active_obstacles.append(obj)
	spawned_count += 1

func _cleanup_obstacles():
	for i in range(active_obstacles.size() - 1, -1, -1):
		var obstacle = active_obstacles[i]
		if not is_instance_valid(obstacle):
			active_obstacles.remove_at(i)
			continue
		if obstacle.global_position.z < player.global_position.z - 300.0:
			active_obstacles.remove_at(i)
			obstacle.queue_free()
