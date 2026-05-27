extends Node

enum GameState{
	BOOT,
	MENU,
	STORY,
	INFINITE,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.BOOT

func _ready() -> void:
	EventBus.player_died.connect(_on_player_died)
	
func set_state(new_state : GameState)	-> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	print("Game State -> ",GameState.keys()[current_state])	

	
func _on_player_died() -> void:
	set_state(GameState.GAME_OVER)
