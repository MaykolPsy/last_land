extends Control


func _on_start_pressed():

	GameStateManager.set_state(
		GameStateManager.GameState.STORY
	)

	EventBus.game_started.emit()

	SceneManager.change_scene(
		"res://scenes/Gameplay.tscn"
	)
