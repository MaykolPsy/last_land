extends Control

func _ready() -> void:
	visible = false
	EventBus.game_over.connect(show_game_over)

func show_game_over() -> void:
	visible = true

func _on_restart_button_pressed() -> void:
	GameStateManager.set_state(GameStateManager.GameState.STORY)
	SceneManager.reload_current_scene()

func _on_menu_button_pressed() -> void:
	GameStateManager.set_state(GameStateManager.GameState.MENU)
	SceneManager.change_scene("res://scenes/MainMenu.tscn")
