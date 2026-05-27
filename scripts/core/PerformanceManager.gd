extends Node

@export var target_fps = 60

func _ready() -> void:
	Engine.max_fps  = target_fps
	print ("PerformanceManager: FPS capped at: ",target_fps)
