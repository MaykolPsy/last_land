extends Node
class_name ObjectPool

@export var scene: PackedScene
@export var initial_size: int = 100

var available_objects: Array[Node] = []

func _ready() -> void:
	if scene == null:
		push_error("ObjectPool requires a PackedScene.")
		return
	for i in range(initial_size):
		var obj = scene.instantiate()
		obj.visible = false
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(obj)
		available_objects.append(obj)
	print("Pool creado con ", available_objects.size(), " objetos")

func get_object() -> Node:
	var obj: Node
	if available_objects.is_empty():
		obj = scene.instantiate()
		add_child(obj)  # Instanciados nuevos sí necesitan padre
	else:
		obj = available_objects.pop_back()

	obj.visible = true
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	return obj  # Sigue siendo hijo del pool, se mueve afuera desde el spawner

func return_object(obj: Node) -> void:
	if obj == null:
		return
	obj.visible = false
	obj.process_mode = Node.PROCESS_MODE_DISABLED

	if obj.get_parent() != self:
		obj.reparent(self)  # reparent() sí funciona aquí porque tiene padre (la escena)

	available_objects.append(obj)
