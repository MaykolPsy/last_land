extends ItemBase

class_name ShieldItem

func collect(player: PlayerControllerBase) -> void:

	player.activate_shield(duracion)

	EventBus.item_collected.emit(item_id)

	queue_free()
