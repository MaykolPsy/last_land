extends Control

@onready var bg: TextureRect = $TextureRect
@onready var menu: Control = $Menu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	GameStateManager.change_state(GameStateManager.GameState.MENU)

	if bg:
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if menu:
		menu.visible = true
		menu.modulate.a = 1.0
