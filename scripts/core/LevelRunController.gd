extends Node
class_name LevelRunController

var finished: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("[LRC] READY path=", get_path())

	if EventBus and EventBus.has_signal("game_started"):
		if not EventBus.game_started.is_connected(_on_game_started):
			EventBus.game_started.connect(_on_game_started)

	reset_run()

func _on_game_started() -> void:
	start_run()

func start_run() -> void:
	print("[LRC] START_RUN called path=", get_path())
	reset_run()
	get_tree().paused = false

	var scene := get_tree().current_scene
	_set_ui_visible(scene, "Menu", false)
	_set_ui_visible(scene, "PauseMenu", false)
	_set_ui_visible(scene, "Victory", false)
	_set_ui_visible(scene, "GameOver", false)

	print("[LRC] start_run paused=", get_tree().paused)

func reset_run() -> void:
	finished = false

func _process(_delta: float) -> void:
	if finished:
		return

	if ScoreManager.get_distance() >= LevelFlowManager.get_current_goal():
		finished = true
		GameStateManager.change_state(GameStateManager.GameState.VICTORY)
		EventBus.game_won.emit()
		print("[LRC] VICTORY reached")

func _set_ui_visible(scene: Node, node_name: String, is_visible: bool) -> void:
	if scene == null:
		return
	var node := scene.find_child(node_name, true, false)
	if node and node is CanvasItem:
		(node as CanvasItem).visible = is_visible
