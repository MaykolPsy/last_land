extends ItemBase

class_name TurboItem

@export var speed_bonus := 8.0

func collect(player: PlayerControllerBase) -> void:
	player.activate_turbo(duracion) # o shield
	var display := nombre if not nombre.is_empty() else item_id.capitalize()
	EventBus.item_collected.emit(item_id, display, duracion)
	emit_item_collected()
	queue_free()
