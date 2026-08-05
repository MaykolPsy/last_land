extends Control

const MAIN_MENU_SCENE := "res://scenes/menus/MainMenu.tscn"

@onready var lbl_score: Label = %LblScore
@onready var lbl_distance: Label = %LblDistance
@onready var btn_retry: Button = %RetryButton
@onready var btn_main_menu: Button = %MenuButton

func _ready() -> void:
	

	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	btn_retry.pressed.connect(_on_retry_pressed)
	btn_main_menu.pressed.connect(_on_main_menu_pressed)
	_style_button_line_hover(btn_main_menu)
	_style_button_line_hover(btn_retry)

func show_game_over() -> void:
	var hud := get_tree().current_scene.find_child("HUD", true, false)
	if hud:
		hud.visible = false

	_refresh_stats()
	visible = true
	get_tree().paused = true

func _refresh_stats() -> void:
	lbl_score.text = "Score: %d" % ScoreManager.score
	lbl_distance.text = "Distance: %d m" % int(ScoreManager.distance)

func _on_retry_pressed() -> void:
	get_tree().paused = false
	LevelFlowManager.restart_level()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	_goto_scene(MAIN_MENU_SCENE)

func _goto_scene(path: String) -> void:
	var sm = get_node_or_null("/root/SceneManager")
	if sm and sm.has_method("change_scene"):
		sm.change_scene(path)
	else:
		get_tree().change_scene_to_file(path)
		
func _style_button_line_hover(btn: Button) -> void:
	if btn == null:
		push_error("Botón null en _style_button_line_hover")
		return

	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())

	var h := StyleBoxFlat.new()
	h.bg_color = Color(0, 0, 0, 0)
	h.border_width_bottom = 4
	h.border_color = Color("472800ff")
	btn.add_theme_stylebox_override("hover", h)
