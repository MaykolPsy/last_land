extends Node


var scene_stack: Array[String] = []
var current_scene: String = ""

@onready var fade_layer: CanvasLayer = CanvasLayer.new()
@onready var fade_rect: ColorRect = ColorRect.new()


func _ready() -> void:
	_setup_fade()
	print("SceneManager ready")
	
	#------------------
	# 	PUBLIC API
	#------------------
	
	
func goto(path:String) -> void:
	if current_scene != "":
		scene_stack.append(current_scene)
			
	_change_scene(path)		
		
func push(path:String) -> void:
	scene_stack.append(current_scene)
	
func pop() -> void:
	if scene_stack.is_empty():
		print("Scene Stack emty")
		return
	
	var previus_scene = scene_stack.pop_back()
	_change_scene(previus_scene)

func load_asyc(path: String, callback: Callable) -> void:
	ResourceLoader.load_threaded_request(path)
	
	while true:
		var status = ResourceLoader.load_threaded_get_status(path)	
		
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(path)
			callback.call(scene)
			break
		await get_tree().process_frame
		

# -------------------------
# INTERNAL
# -------------------------

func _change_scene(path: String) -> void:
	_fade_out()

	get_tree().change_scene_to_file(path)

	current_scene = path

	EventBus.biome_changed.emit(path)

	_fade_in()


func _setup_fade() -> void:
	fade_layer.layer = 100

	fade_rect.color = Color.BLACK
	fade_rect.anchor_left = 0
	fade_rect.anchor_top = 0
	fade_rect.anchor_right = 1
	fade_rect.anchor_bottom = 1

	fade_layer.add_child(fade_rect)
	add_child(fade_layer)


func _fade_out() -> void:
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0


func _fade_in() -> void:
	fade_rect.modulate.a = 0.0
	fade_rect.visible = false


	
	
