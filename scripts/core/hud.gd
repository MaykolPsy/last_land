extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var distance_label: Label = %DistanceLabel
@onready var item_label: Label = %ItemLabel
@onready var shield_label: Label = %ShieldLabel
@onready var pause_button: Button = %PauseButton

var _item_msg_version := 0

func _ready():
	visible = true
	_style_button_line_hover(pause_button)
	pause_button.pressed.connect(_on_pause_pressed)

	if EventBus.has_signal("player_died"):
		EventBus.player_died.connect(_on_player_died)

	if not EventBus.item_collected.is_connected(_on_item_collected):
		EventBus.item_collected.connect(_on_item_collected)

	EventBus.score_updated.connect(_on_score_updated)
	EventBus.distance_updated.connect(_on_distance_updated)
	EventBus.shield_changed.connect(_on_shield_changed)

	_on_score_updated(ScoreManager.score)
	_on_distance_updated(ScoreManager.distance)
	_on_shield_changed(false)

	item_label.visible = false
	shield_label.visible = false

func _on_score_updated(score: int):
	score_label.text = " %d" % score

func _on_distance_updated(distance: float):
	distance_label.text = "%d m" % int(distance)

func _on_item_collected(item_id: String, display_name: String, duration: float) -> void:
	var id := item_id.strip_edges().to_lower()

	# Shield: no usar item_label (ya existe shield_label)
	if id == "shield" or id == "shielditem":
		item_label.visible = false
		return

	# Turbo: mostrar solo texto corto, sin "(4.0s)"
	if id == "turbo" or id == "turboitem":
		item_label.visible = true
		item_label.text = "Turbo!"
		_item_msg_version += 1
		var vt := _item_msg_version
		_hide_item_label_later(vt)
		return

	# Otros items
	item_label.visible = true
	item_label.text = "%s (%.1fs)" % [display_name, duration]
	_item_msg_version += 1
	var v := _item_msg_version
	_hide_item_label_later(v)

func _hide_item_label_later(v: int) -> void:
	await get_tree().create_timer(2.0).timeout
	if v == _item_msg_version:
		item_label.visible = false

func _on_shield_changed(active: bool):
	shield_label.visible = active
	shield_label.text = "Shield: ON" if active else "Shield: OFF"

func _on_pause_pressed() -> void:
	var pause_menu := get_tree().current_scene.find_child("PauseMenu", true, false)
	if pause_menu == null:
		push_error("No se encontró PauseMenu")
		return

	if GameStateManager.current_state == GameStateManager.GameState.PAUSED:
		pause_menu.call("hide_pause")
	else:
		pause_menu.call("show_pause")

func _style_button_line_hover(btn: Button) -> void:
	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())

	var h := StyleBoxFlat.new()
	h.bg_color = Color(0, 0, 0, 0)
	h.border_width_bottom = 0
	h.border_color = Color("472800ff")
	btn.add_theme_stylebox_override("hover", h)

func _on_player_died() -> void:
	visible = false
	if GameStateManager.has_method("change_state"):
		GameStateManager.change_state(GameStateManager.GameState.GAME_OVER)

	var game_over := get_tree().current_scene.find_child("GameOver", true, false)
	if game_over and game_over.has_method("show_game_over"):
		game_over.show_game_over()
	else:
		push_error("No se encontró GameOver o no tiene show_game_over()")
