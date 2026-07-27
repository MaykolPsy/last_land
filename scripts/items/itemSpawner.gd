extends Node3D

@export var items:Array[PackedScene]

func spawn_item(position):

	var item = items.pick_random().instantiate()

	add_child(item)

	item.global_position = position
