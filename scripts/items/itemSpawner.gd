extends Node3D

@export var items: Array[PackedScene]
@export var player_path: NodePath
@export var min_spawn_ahead: float = 120.0

var player: Node3D

func _ready() -> void:
	player = get_node_or_null(player_path) as Node3D

func can_spawn_at(z_pos: float) -> bool:
	if player == null:
		return true
	return z_pos >= player.global_position.z + min_spawn_ahead

func spawn_item(position: Vector3) -> void:
	if items.is_empty():
		return
	if not can_spawn_at(position.z):
		return

	var item = items.pick_random().instantiate()
	add_child(item)
	item.global_position = position
