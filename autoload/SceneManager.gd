extends Node


func change_scene(path:String) -> void:

		get_tree().change_scene_to_file(path)



func reload_current_scene() -> void:

	get_tree().reload_current_scene()
