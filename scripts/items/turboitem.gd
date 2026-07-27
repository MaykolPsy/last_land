extends ItemBase

class_name TurboItem

@export var speed_bonus := 8.0

func collect(player: PlayerControllerBase) -> void:

	player.activate_turbo(duracion)

	EventBus.item_collected.emit(item_id)

	queue_free()
