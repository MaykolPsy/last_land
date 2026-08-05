extends Area3D
class_name HitboxArea

signal hit_detected(area)

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	hit_detected.emit(area)
