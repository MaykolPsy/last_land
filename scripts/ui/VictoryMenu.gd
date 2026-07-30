extends Control

@onready var next_btn: Button = %NextButton
@onready var retry_btn: Button = %RetrytButton 
@onready var menu_btn: Button =%MenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_btn.pressed.connect(_on_next_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

func _on_next_pressed() -> void:
	get_tree().paused = false
	var has_next := LevelFlows.next_level()
	if not has_next:
		# si ya no hay nivel siguiente, vuelve al menú
		SceneManager.change_scene("res://scenes/menus/MainMenu.tscn")

func _on_retry_pressed() -> void:
	get_tree().paused = false
	LevelFlows.restart_level()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	LevelFlows.reset_run()
	SceneManager.change_scene("res://scenes/menus/MainMenu.tscn")
