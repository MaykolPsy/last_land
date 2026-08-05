extends Node3D
class_name ItemBase

@export var item_id: String = ""
@export var nombre: String = ""
@export var duracion: float = 0.0

@onready var pickup_area: Area3D = $Area3D
var collected := false

func _ready() -> void:
	pickup_area.monitoring = true
	pickup_area.monitorable = true

	if not pickup_area.body_entered.is_connected(_on_body_entered):
		pickup_area.body_entered.connect(_on_body_entered)
	if not pickup_area.area_entered.is_connected(_on_area_entered):
		pickup_area.area_entered.connect(_on_area_entered)

	print("[ItemBase] ready ", name)

func _on_body_entered(body: Node) -> void:
	print("[ItemBase] body_entered -> ", body.name, " ", body.get_class())
	_try_collect(body)

func _on_area_entered(area: Area3D) -> void:
	print("[ItemBase] area_entered -> ", area.name)
	_try_collect(area.get_parent())

func _try_collect(node: Node) -> void:
	if collected:
		return
	var player := node as PlayerControllerBase
	if player == null:
		return
	collected = true
	collect(player)

func collect(_player: PlayerControllerBase) -> void:
	pass
	
func emit_item_collected() -> void:
	var display := nombre if not nombre.is_empty() else item_id.capitalize()
	EventBus.item_collected.emit(item_id, display, duracion)
