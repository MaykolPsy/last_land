extends Node3D

@onready var pause_menu: Control = $CanvasLayer/PauseMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if GameStateManager.current_state == GameStateManager.GameState.PAUSED:
			pause_menu.hide_pause()
		else:
			pause_menu.show_pause()
