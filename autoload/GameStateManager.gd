extends Node

enum GameState {
	BOOT, MENU, STORY, INFINITE, PAUSED, GAME_OVER, VICTORY
}

var current_state: GameState = GameState.BOOT

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)

func set_state(new_state: GameState) -> void:
	change_state(new_state)

func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	var should_pause := (
		current_state == GameState.PAUSED
		or current_state == GameState.GAME_OVER
		or current_state == GameState.VICTORY
	)

	get_tree().paused = should_pause

	if should_pause:
		EventBus.game_paused.emit()
	else:
		EventBus.game_resumed.emit()

	if current_state == GameState.STORY or current_state == GameState.INFINITE:
		EventBus.game_started.emit()

	print("[GSM] state=", GameState.keys()[current_state], " paused=", get_tree().paused)

func _on_player_died() -> void:
	change_state(GameState.GAME_OVER)
	EventBus.game_over.emit()
