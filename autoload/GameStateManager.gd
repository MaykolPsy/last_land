extends Node

enum GameState {
	BOOT, MENU, STORY, INFINITE, PAUSED, GAME_OVER
}

var current_state: GameState = GameState.BOOT

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)

func set_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	print("Game State -> ", GameState.keys()[current_state])

	# Pausar en PAUSED y GAME_OVER
	var should_pause := (
		current_state == GameState.PAUSED
		or current_state == GameState.GAME_OVER
	)

	get_tree().paused = should_pause

	if should_pause:
		EventBus.game_paused.emit()
	else:
		EventBus.game_resumed.emit()

func _on_player_died() -> void:
	set_state(GameState.GAME_OVER)
	EventBus.game_over.emit()
