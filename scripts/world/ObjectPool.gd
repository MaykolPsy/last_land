extends Node
class_name ObjectPool

@export var scene: PackedScene
@export var initial_size: int = 100
@export var spawn_scale: Vector3 = Vector3.ONE # <- tamaño de salida (ej: (3,3,3))

var available_objects: Array[Node] = []

func _ready() -> void:
	if scene == null:
		push_error("ObjectPool requires a PackedScene.")
		return

	for i in range(initial_size):
		var obj := scene.instantiate()
		obj.visible = false
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(obj)
		available_objects.append(obj)

func get_object() -> Node:
	var obj: Node

	if available_objects.is_empty():
		obj = scene.instantiate()
		add_child(obj)
	else:
		obj = available_objects.pop_back()

	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.scale = spawn_scale
	return obj

func return_object(obj: Node) -> void:
	if obj == null:
		return

	obj.visible = false
	obj.process_mode = Node.PROCESS_MODE_DISABLED

	if obj.get_parent() != self:
		obj.reparent(self)

	available_objects.append(obj)
