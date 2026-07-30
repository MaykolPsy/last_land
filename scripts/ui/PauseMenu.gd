extends Control

const MAIN_MENU_SCENE := "res://scenes/MainMenu.tscn" # ajusta si ahora es Main.tscn

@onready var panel: Panel = find_child("Panel", true, false) as Panel
@onready var overlay: ColorRect = find_child("Overlay", true, false) as ColorRect
@onready var title: Label = find_child("Title", true, false) as Label
@onready var play_button: Button = find_child("PlayButton", true, false) as Button
@onready var menu_button: Button = find_child("MenuButton", true, false) as Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	visible = false

	_style_button_line_hover(play_button)
	_style_button_line_hover(menu_button)

	_debug_nodes()
	_connect_signals()

func _debug_nodes() -> void:
	print("panel:", panel)
	print("overlay:", overlay)
	print("title:", title)
	print("play_button:", play_button)
	print("menu_button:", menu_button)

func _connect_signals() -> void:
	if play_button == null:
		push_error("PauseMenu: PlayButton no encontrado")
	elif not play_button.pressed.is_connected(_on_play_button_pressed):
		play_button.pressed.connect(_on_play_button_pressed)

	if menu_button == null:
		push_error("PauseMenu: MenuButton no encontrado")
	elif not menu_button.pressed.is_connected(_on_menu_button_pressed):
		menu_button.pressed.connect(_on_menu_button_pressed)

func show_pause() -> void:
	visible = true
	GameStateManager.change_state(GameStateManager.GameState.PAUSED)
	if play_button:
		play_button.grab_focus()

func _on_play_button_pressed() -> void:
	hide_pause()

func hide_pause() -> void:
	visible = false
	GameStateManager.change_state(GameStateManager.GameState.STORY)

func _on_menu_button_pressed() -> void:
	hide_pause()
	GameStateManager.change_state(GameStateManager.GameState.MENU)

	var sm = get_node_or_null("/root/SceneManager")
	if sm and sm.has_method("change_scene"):
		sm.change_scene(MAIN_MENU_SCENE)
	else:
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _style_button_line_hover(btn: Button) -> void:
	if btn == null:
		return

	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())

	var h := StyleBoxFlat.new()
	h.bg_color = Color(0, 0, 0, 0)
	h.border_width_bottom = 3
	h.border_color = Color("472800ff")
	btn.add_theme_stylebox_override("hover", h)
