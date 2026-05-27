extends Node

const SAVE_PATH := "user://settings.cfg"

var master_vol: float = 1.0
var music_vol: float = 1.0
var sfx_vol: float = 1.0

var fullscreen: bool = false
var colorblind_mode: bool = false
var rumble_enabled: bool = true
	
func _ready():
	load_settings()
	apply_settings()

func apply_settings():
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")

	if master_bus != -1:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_vol))

	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_vol))

	if sfx_bus != -1:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_vol))

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func save_settings():
	var file = ConfigFile.new()

	file.set_value("audio", "master_vol", master_vol)
	file.set_value("audio", "music_vol", music_vol)
	file.set_value("audio", "sfx_vol", sfx_vol)

	file.set_value("video", "fullscreen", fullscreen)

	file.set_value("game", "colorblind_mode", colorblind_mode)
	file.set_value("game", "rumble_enabled", rumble_enabled)

	file.save(SAVE_PATH)

func load_settings():
	var file = ConfigFile.new()

	if file.load(SAVE_PATH) != OK:
		return

	master_vol = file.get_value("audio", "master_vol", 1.0)
	music_vol = file.get_value("audio", "music_vol", 1.0)
	sfx_vol = file.get_value("audio", "sfx_vol", 1.0)

	fullscreen = file.get_value("video", "fullscreen", false)

	colorblind_mode = file.get_value("game", "colorblind_mode", false)
	rumble_enabled = file.get_value("game", "rumble_enabled", true)
