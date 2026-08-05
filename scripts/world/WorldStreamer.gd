extends Node3D
class_name WorldStreamer

@export var chunk_scene: PackedScene
@export var chunk_length: float = 120.0
@export var chunks_ahead: int = 10
@export var chunks_behind: int = 3
@export var lanes: Array[float] = [-120.0, 0.0, 120.0]
@export var forward_sign_z: float = 1.0 # 1 => +Z, -1 => -Z

@export var player_path: NodePath
var player: Node3D

var active_chunks: Array[Node3D] = []
var next_spawn_z: float = 0.0
var pool: ObjectPool

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	pool = get_parent().get_node_or_null("OceanPool") as ObjectPool
	player = get_node_or_null(player_path) as Node3D

	if player == null:
		push_error("WorldStreamer: player_path no asignado")
		return

	# empieza justo delante del player
	next_spawn_z = player.position.z

	for i in range(4):
		_spawn_chunk_row()
		await get_tree().process_frame

func _process(_delta: float) -> void:
	if player == null:
		return
	_spawn_if_needed()
	_cleanup_behind()

func _spawn_if_needed() -> void:
	while _needs_more_chunks():
		_spawn_chunk_row()

func _needs_more_chunks() -> bool:
	if active_chunks.is_empty():
		return true

	var last_chunk := active_chunks[active_chunks.size() - 1]
	var front_limit := player.position.z + (chunks_ahead * chunk_length * forward_sign_z)

	if forward_sign_z > 0.0:
		return last_chunk.position.z < front_limit
	else:
		return last_chunk.position.z > front_limit

func _spawn_chunk_row() -> void:
	for lane_x in lanes:
		var chunk := _get_chunk_from_pool()
		if chunk == null:
			continue

		if chunk.get_parent() != self:
			if chunk.get_parent() != null:
				chunk.get_parent().remove_child(chunk)
			add_child(chunk)

		chunk.visible = true
		chunk.process_mode = Node.PROCESS_MODE_INHERIT
		chunk.position = Vector3(lane_x, 0.0, next_spawn_z)
		chunk.rotation = Vector3.ZERO
		chunk.scale = Vector3.ONE
		active_chunks.append(chunk)

	next_spawn_z += chunk_length * forward_sign_z

func _get_chunk_from_pool() -> Node3D:
	if pool != null:
		return pool.get_object() as Node3D
	return chunk_scene.instantiate() as Node3D

func _cleanup_behind() -> void:
	var back_limit := player.position.z - (chunks_behind * chunk_length * forward_sign_z)

	for i in range(active_chunks.size() - 1, -1, -1):
		var chunk := active_chunks[i]

		var should_remove := false
		if forward_sign_z > 0.0:
			should_remove = chunk.position.z < back_limit
		else:
			should_remove = chunk.position.z > back_limit

		if should_remove:
			_return_chunk(chunk)
			active_chunks.remove_at(i)

func _return_chunk(chunk: Node3D) -> void:
	chunk.visible = false
	chunk.process_mode = Node.PROCESS_MODE_DISABLED

	if pool != null:
		if chunk.get_parent() != pool:
			if chunk.get_parent() != null:
				chunk.get_parent().remove_child(chunk)
			pool.add_child(chunk)
		pool.return_object(chunk)
	else:
		chunk.queue_free()
