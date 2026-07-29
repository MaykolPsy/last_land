extends Node3D
class_name WorldStreamer

@export var chunk_scene: PackedScene
@export var chunk_length: float = 120.0
@export var chunks_ahead: int = 10
@export var chunks_behind: int = 3
var lanes := [-120.0, 0.0, 120.0]

@export var player_path: NodePath
var player: Node3D

var active_chunks: Array[Node3D] = []
var next_spawn_z: float = 0.0

var pool: ObjectPool

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	pool = get_parent().get_node("OceanPool")
	player = get_node(player_path)
	_init_stream()

func _process(_delta: float) -> void:
	_update_stream()

func _init_stream() -> void:
	for _i in range(chunks_ahead):
		_spawn_chunk_row()

func _update_stream() -> void:
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
	return last_chunk.position.z < player.position.z + (chunks_ahead * chunk_length)

func _spawn_chunk_row() -> void:
	for lane_x in lanes:
		var chunk := _get_chunk_from_pool()

		# Si viene de otro padre, lo reparent con keep_global=false
		if chunk.get_parent() != self:
			if chunk.get_parent() != null:
				chunk.get_parent().remove_child(chunk)
			add_child(chunk)

		chunk.visible = true
		chunk.process_mode = Node.PROCESS_MODE_INHERIT

		# IMPORTANTE: local_position exacta
		chunk.position = Vector3(lane_x, 0.0, next_spawn_z)
		chunk.rotation = Vector3.ZERO
		chunk.scale = Vector3.ONE

		active_chunks.append(chunk)

	next_spawn_z += chunk_length

func _get_chunk_from_pool() -> Node3D:
	if pool != null:
		return pool.get_object() as Node3D
	return chunk_scene.instantiate() as Node3D

func _cleanup_behind() -> void:
	for i in range(active_chunks.size() - 1, -1, -1):
		var chunk := active_chunks[i]
		if chunk.position.z < player.position.z - (chunks_behind * chunk_length):
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

func get_lanes() -> Array:
	return lanes
