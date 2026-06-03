extends Area3D
class_name HurtboxArea

signal near_miss(area)

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	near_miss.emit(area)
