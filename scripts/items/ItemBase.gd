extends Node3D

class_name ItemBase

@export var item_id: String = ""
@export var nombre: String = ""
@export var duracion: float = 0.0
@export var pickup_sound: AudioStream
@export var icon: Texture2D

@onready var pickup_area: Area3D = $Area3D


func _ready() -> void:
	if pickup_area == null:
		push_error("ItemBase requiere un nodo Area3D como hijo.")
		return

	pickup_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body is PlayerControllerBase:
		collect(body)


func collect(player: PlayerControllerBase) -> void:
	pass
