extends Node
class_name ObstacleSpawner

@export var player_path: NodePath
@export var world_streamer_path: NodePath
@export var obstacles_root_path: NodePath

@export_group("Direction")
@export var forward_sign_z: float = 1.0 # 1.0 => avanza +Z, -1.0 => avanza -Z
@export var cleanup_behind_distance: float = 250.0

@export_group("Spawn")
@export var spawn_distance_ahead: float = 500.0
@export var min_spawn_ahead: float = 60.0
@export var min_spacing: float = 6.0
@export var max_spacing: float = 14.0
@export_range(0.0, 1.0) var density: float = 0.95
@export var z_jitter_range: float = 3.0

@export_group("Obstacle")
@export var obstacle_scale: Vector3 = Vector3(6, 6, 6)
@export var obstacle_scenes: Array[PackedScene]
@export var y_rotation_random: bool = true
@export var y_rotation_min_deg: float = -35.0
@export var y_rotation_max_deg: float = 35.0
@export var water_sink_y: float = -1.5

# ancho util del chunk (ajústalo en inspector)
@export_group("Lane Width")
@export var chunk_half_width: float = 170.0
@export var edge_margin: float = 15.0

var player: Node3D
var world_streamer: WorldStreamer
var obstacles_root: Node

var active_obstacles: Array[Node3D] = []
var furthest_spawn_z: float = 0.0

func _ready() -> void:
	player = get_node_or_null(player_path) as Node3D
	world_streamer = get_node_or_null(world_streamer_path) as WorldStreamer
	obstacles_root = get_node_or_null(obstacles_root_path)
	if obstacles_root == null:
		obstacles_root = get_parent()

	if player == null or world_streamer == null:
		push_error("ObstacleSpawner: referencias faltantes")
		return

	# primer punto de spawn delante del jugador según dirección
	furthest_spawn_z = player.global_position.z + (min_spawn_ahead * forward_sign_z)
	call_deferred("_initial_spawn")

func _initial_spawn() -> void:
	await get_tree().process_frame
	for _i in range(20):
		_spawn_if_needed()

func _process(_delta: float) -> void:
	_spawn_if_needed()
	_cleanup_obstacles()

func _spawn_if_needed() -> void:
	var base_z: float = player.global_position.z
	var target_z: float = base_z + (spawn_distance_ahead * forward_sign_z)

	if forward_sign_z > 0.0:
		while furthest_spawn_z < target_z:
			if randf() <= density:
				_spawn_obstacle(furthest_spawn_z)
			furthest_spawn_z += randf_range(min_spacing, max_spacing)
	else:
		while furthest_spawn_z > target_z:
			if randf() <= density:
				_spawn_obstacle(furthest_spawn_z)
			furthest_spawn_z -= randf_range(min_spacing, max_spacing)

func _spawn_obstacle(z_pos: float) -> void:
	if obstacle_scenes.is_empty():
		return

	var scene: PackedScene = obstacle_scenes[randi() % obstacle_scenes.size()]
	var obj := scene.instantiate() as Node3D
	if obj == null:
		return

	obstacles_root.add_child(obj)

	var min_x: float = -chunk_half_width + edge_margin
	var max_x: float =  chunk_half_width - edge_margin
	var x: float = randf_range(min_x, max_x)
	var z_jitter: float = randf_range(-z_jitter_range, z_jitter_range)

	obj.global_position = Vector3(x, water_sink_y, z_pos + z_jitter)
	obj.scale = obstacle_scale
	obj.rotation_degrees.y = randf_range(y_rotation_min_deg, y_rotation_max_deg) if y_rotation_random else 0.0

	active_obstacles.append(obj)

func _cleanup_obstacles() -> void:
	for i in range(active_obstacles.size() - 1, -1, -1):
		var obstacle := active_obstacles[i]
		if not is_instance_valid(obstacle):
			active_obstacles.remove_at(i)
			continue

		if forward_sign_z > 0.0:
			if obstacle.global_position.z < player.global_position.z - cleanup_behind_distance:
				active_obstacles.remove_at(i)
				obstacle.queue_free()
		else:
			if obstacle.global_position.z > player.global_position.z + cleanup_behind_distance:
				active_obstacles.remove_at(i)
				obstacle.queue_free()
