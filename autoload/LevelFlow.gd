extends Node
class_name LevelFlow

const LEVEL_SCENES := [
	"res://scenes/levels/Level_01_Water.tscn",
	"res://scenes/levels/Level_02_Islands.tscn",
	"res://scenes/levels/Level_03_Snow.tscn"
]

const LEVEL_GOALS := [200.0, 300.0, 400.0]

var current_level: int = 0

func get_current_scene_path() -> String:
	return LEVEL_SCENES[current_level]

func get_current_goal() -> float:
	return LEVEL_GOALS[current_level]

func load_current_level() -> void:
	var sm := get_node_or_null("/root/SceneManager")
	if sm and sm.has_method("change_scene"):
		sm.change_scene(get_current_scene_path())
	else:
		get_tree().change_scene_to_file(get_current_scene_path())

func next_level() -> bool:
	if current_level < LEVEL_SCENES.size() - 1:
		current_level += 1
		load_current_level()
		return true
	return false

func restart_level() -> void:
	load_current_level()

func reset_run() -> void:
	current_level = 0
