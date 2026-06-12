extends Node
class_name ObstacleSpawner

@export var player_path: NodePath
@export var world_streamer_path: NodePath

@export var spawn_distance_ahead := 1200.0
@export var min_spacing := 15.0
@export var max_spacing := 60.0

@export_range(0.0, 1.0)
var density := 1.0

@export var level_length := 2000.0

@export var obstacle_scenes: Array[PackedScene]

var level := 1
var player: Node3D
var world_streamer: WorldStreamer

var active_obstacles: Array[Node3D] = []
var furthest_spawn_z := 0.0
var lane_last_spawn_z: Dictionary = {}

# ---------------------------
# INIT
# ---------------------------
func _ready():
	player = get_parent().get_node_or_null("CharacterBody3D")
	world_streamer = get_parent().get_node_or_null("WorldStreamer")

	if player == null or world_streamer == null:
		push_error("ObstacleSpawner: referencias faltantes")
		return

	furthest_spawn_z = max(player.global_position.z, 0.0)
	call_deferred("_initial_spawn")

# ---------------------------
# INITIAL SPAWN
# ---------------------------
func _initial_spawn():
	await get_tree().process_frame
	for i in range(25):
		_spawn_if_needed()

# ---------------------------
# LOOP
# ---------------------------
func _process(_delta):
	if player == null:
		return

	_update_level()
	_update_difficulty()
	_spawn_if_needed()
	_cleanup_obstacles()

# ---------------------------
# LEVEL
# ---------------------------
func _update_level():
	level = int(player.global_position.z / level_length) + 1

# ---------------------------
# DIFFICULTY
# ---------------------------
func _update_difficulty():
	density = clamp(0.8 + (level * 0.05), 0.5, 0.95)
	min_spacing = max(10.0, 40.0 - level * 2.0)
	max_spacing = max(25.0, 70.0 - level * 3.0)

# ---------------------------
# SPAWN LOOP
# ---------------------------
func _spawn_if_needed():
	var base_z = player.global_position.z
	while furthest_spawn_z < base_z + spawn_distance_ahead:
		if randf() <= density:
			_spawn_obstacle()

		furthest_spawn_z += randf_range(min_spacing, max_spacing)

# ---------------------------
# SPAWN OBSTACLE
# ---------------------------
func _spawn_obstacle():
	if world_streamer == null:
		return

	var lanes = world_streamer.get_lanes()
	if lanes == null or lanes.is_empty():
		return

	if obstacle_scenes == null or obstacle_scenes.is_empty():
		return

	var x = randf_range(lanes.min(), lanes.max())

	var scene = obstacle_scenes[randi() % obstacle_scenes.size()]
	var obj = scene.instantiate()

	if obj == null:
		return

	get_tree().current_scene.add_child(obj)
	obj.global_position = Vector3(x, 0.0, furthest_spawn_z)

	active_obstacles.append(obj)
	print("SPAWN OBSTACLE EN Z:", furthest_spawn_z, " X:", x)

# ---------------------------
# CLEANUP
# ---------------------------
func _cleanup_obstacles():
	if player == null:
		return

	for i in range(active_obstacles.size() - 1, -1, -1):
		var obstacle = active_obstacles[i]

		if not is_instance_valid(obstacle):
			active_obstacles.remove_at(i)
			continue

		if obstacle.global_position.z < player.global_position.z - 300.0:
			active_obstacles.remove_at(i)

			# NO POOLS: solo liberar escena
			obstacle.queue_free()
