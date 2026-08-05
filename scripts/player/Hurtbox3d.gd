extends Area3D
class_name HurtboxArea

signal near_miss(area)

@export var player_path: NodePath
var player: PlayerControllerBase
var _hit_lock := false

func _ready() -> void:
	player = get_node_or_null(player_path) as PlayerControllerBase
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	if _hit_lock:
		return
	_hit_lock = true

	near_miss.emit(area)

	if player == null:
		_hit_lock = false
		return

	# Si es pickup, no tratar como obstáculo
	if area.is_in_group("pickups"):
		_hit_lock = false
		return

	if player.shield_active:
		# destruir obstáculo y seguir
		if EventBus.has_signal("camera_shake"):
			EventBus.camera_shake.emit(3.0)

		# intenta borrar el obstáculo completo
		var obstacle := area.get_parent()
		if obstacle and obstacle != self and obstacle != player:
			obstacle.queue_free()
		else:
			area.queue_free()

		_hit_lock = false
		return

	# sin shield => daño/muerte
	player.die()
	_hit_lock = false
