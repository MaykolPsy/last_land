extends CanvasLayer

@onready var score_label: Label = %ScoreLabel
@onready var distance_label: Label = %DistanceLabel
@onready var item_label: Label = %ItemLabel
@onready var shield_label: Label = %ShieldLabel
@onready var pause_button: Button = %PauseButton


func _ready():
	_style_button_line_hover(pause_button)
	pause_button.pressed.connect(_on_pause_pressed)

	EventBus.score_updated.connect(_on_score_updated)
	EventBus.distance_updated.connect(_on_distance_updated)
	EventBus.item_collected.connect(_on_item_collected)
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
	
	
func _on_item_collected(item_id: String):
	item_label.visible = true
	match item_id:
		"turbo":
			item_label.text = "Turbo"

		"shield":
			item_label.text = "Shield"

		_:
			item_label.text = "Item: Unknown"
			
			
			
func _on_shield_changed(active: bool):
	
	shield_label.visible = active
	
	if active:
		shield_label.text = "Shield Active"

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
	h.bg_color = Color(0, 0, 0, 0) # transparente
	h.border_width_bottom = 0
	h.border_color = Color("472800ff") # color de línea
	btn.add_theme_stylebox_override("hover", h)
