extends Control

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func show_pause() -> void:
	visible = true
	GameStateManager.set_state(GameStateManager.GameState.PAUSED)

func hide_pause() -> void:
	visible = false
	GameStateManager.set_state(GameStateManager.GameState.STORY)

func _on_resume_button_pressed() -> void:
	hide_pause()

func _on_menu_button_pressed() -> void:
	GameStateManager.set_state(GameStateManager.GameState.MENU)
	SceneManager.change_scene("res://scenes/MainMenu.tscn")
