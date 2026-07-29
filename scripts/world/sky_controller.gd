extends Node3D
class_name SkyController

@export var auto_progress: bool = true
@export_range(5.0, 180.0, 1.0) var seconds_to_full_storm: float = 30.0

@export_range(1, 10, 1) var clouds_start_level: int = 4
@export_range(1, 10, 1) var clouds_end_level: int = 10
@export_range(40.0, 220.0, 1.0) var clouds_start_height: float = 110.0
@export_range(40.0, 220.0, 1.0) var clouds_end_height: float = 90.0
@export var clouds_size: Vector3 = Vector3(1200.0, 220.0, 1200.0)

@export_range(1, 10, 1) var sky_start_darkness: int = 2
@export_range(1, 10, 1) var sky_end_darkness: int = 10

@export_range(1, 10, 1) var lightning_intensity: int = 7
@export_range(1, 10, 1) var lightning_starts_when_storm_is: int = 6

@export var player_path: NodePath
@export_range(0.1, 5.0, 0.1) var cloud_follow_speed: float = 1.0

# Luz principal del nivel (sol)
@export var main_sun_path: NodePath

var weather_progress: float = 0.0
var lightning_timer: float = 0.0
var player_ref: Node3D
var main_sun: DirectionalLight3D

@onready var env_node: WorldEnvironment = get_node_or_null("WorldEnvironment")
@onready var clouds_node: FogVolume = get_node_or_null("CloudFog")
@onready var lightning_node: DirectionalLight3D = get_node_or_null("LightningLight")

func _ready() -> void:
	randomize()
	player_ref = get_node_or_null(player_path) as Node3D
	main_sun = get_node_or_null(main_sun_path) as DirectionalLight3D

	_ensure_nodes_exist()
	_setup_environment()
	_setup_clouds()
	_apply_weather(0.0)
	_reset_lightning_timer()

func _process(delta: float) -> void:
	_follow_player_with_clouds(delta)

	if auto_progress:
		weather_progress = clampf(weather_progress + delta / max(seconds_to_full_storm, 0.01), 0.0, 1.0)

	_apply_weather(weather_progress)
	_update_lightning(delta)

func set_progress(p: float) -> void:
	weather_progress = clampf(p, 0.0, 1.0)
	_apply_weather(weather_progress)

func _ensure_nodes_exist() -> void:
	if env_node == null:
		env_node = WorldEnvironment.new()
		env_node.name = "WorldEnvironment"
		add_child(env_node)

	if clouds_node == null:
		clouds_node = FogVolume.new()
		clouds_node.name = "CloudFog"
		add_child(clouds_node)

	if lightning_node == null:
		lightning_node = DirectionalLight3D.new()
		lightning_node.name = "LightningLight"
		lightning_node.light_color = Color.html("#DDEBFF")
		lightning_node.shadow_enabled = false
		lightning_node.light_energy = 0.0
		add_child(lightning_node)

func _setup_environment() -> void:
	if env_node.environment == null:
		env_node.environment = Environment.new()

	var env := env_node.environment
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.0012
	env.volumetric_fog_albedo = Color.html("#cfd8e6")

func _setup_clouds() -> void:
	clouds_node.size = clouds_size
	clouds_node.position = Vector3(0.0, clouds_start_height, 0.0)

	var mat := FogMaterial.new()
	mat.density = _cloud_density_from_level(clouds_start_level)
	mat.albedo = Color.html("#E7EDF8")
	mat.emission = Color.BLACK
	mat.height_falloff = 0.05
	clouds_node.material = mat

func _apply_weather(t: float) -> void:
	if env_node == null or env_node.environment == null:
		return

	var k := smoothstep(0.0, 1.0, t)
	_apply_sky_colors(k)
	_apply_clouds(k)

func _apply_sky_colors(k: float) -> void:
	var env := env_node.environment
	var sky := Sky.new()
	var psky := ProceduralSkyMaterial.new()

	var sunset_top_light := Color.html("#F19A6B")
	var sunset_horizon_light := Color.html("#FFD3A1")
	var sunset_top_dark := Color.html("#8A5A52")
	var sunset_horizon_dark := Color.html("#A8786A")

	var storm_top_dark := Color.html("#06090F")
	var storm_horizon_dark := Color.html("#111827")

	var d0 := _level01(sky_start_darkness)
	var d1 := _level01(sky_end_darkness)

	var sky_start_top := sunset_top_light.lerp(sunset_top_dark, d0)
	var sky_start_horizon := sunset_horizon_light.lerp(sunset_horizon_dark, d0)

	psky.sky_top_color = sky_start_top.lerp(storm_top_dark, k * d1)
	psky.sky_horizon_color = sky_start_horizon.lerp(storm_horizon_dark, k * d1)
	psky.ground_bottom_color = Color.html("#2C2A2F").lerp(Color.html("#0B0E14"), k)
	psky.ground_horizon_color = Color.html("#4A4144").lerp(Color.html("#151A24"), k)

	sky.sky_material = psky
	env.sky = sky
	env.ambient_light_energy = lerpf(1.0, 0.10, k)

	# Luz principal del nivel (se apaga con tormenta)
	if main_sun:
		main_sun.light_energy = lerpf(2.2, 0.35, k)
		main_sun.light_color = Color(1.0, 0.96, 0.90).lerp(Color(0.72, 0.78, 0.95), k)

func _apply_clouds(k: float) -> void:
	if clouds_node == null or not (clouds_node.material is FogMaterial):
		return

	var mat := clouds_node.material as FogMaterial
	var d_start := _cloud_density_from_level(clouds_start_level)
	var d_end := _cloud_density_from_level(clouds_end_level)

	mat.density = lerpf(d_start, d_end, k)
	mat.albedo = Color.html("#EAF0FA").lerp(Color.html("#232B37"), k)
	mat.emission = Color.BLACK
	mat.height_falloff = lerpf(0.04, 0.11, k)

	clouds_node.position.y = lerpf(clouds_start_height, clouds_end_height, k)
	clouds_node.size = clouds_size

func _update_lightning(delta: float) -> void:
	if lightning_node == null:
		return

	var start_k := _level01(lightning_starts_when_storm_is)
	if weather_progress < start_k:
		lightning_node.light_energy = 0.0
		return

	lightning_timer -= delta
	if lightning_timer > 0.0:
		return

	var lv := _level01(lightning_intensity)
	var flashes := int(lerpf(1.0, 4.0, lv))
	var power := lerpf(1.0, 4.0, lv)

	var tw := create_tween()
	for _i in range(flashes):
		tw.tween_property(lightning_node, "light_energy", power * randf_range(0.7, 1.0), randf_range(0.03, 0.08))
		tw.tween_property(lightning_node, "light_energy", 0.0, randf_range(0.05, 0.12))

	_reset_lightning_timer()

func _reset_lightning_timer() -> void:
	var lv := _level01(lightning_intensity)
	lightning_timer = randf_range(lerpf(8.0, 1.2, lv), lerpf(14.0, 3.0, lv))

func _follow_player_with_clouds(delta: float) -> void:
	if clouds_node == null or player_ref == null:
		return
	var target_z := player_ref.global_position.z
	clouds_node.global_position.z = lerpf(
		clouds_node.global_position.z,
		target_z,
		clampf(delta * 4.0 * cloud_follow_speed, 0.0, 1.0)
	)

func _level01(v: int) -> float:
	return clampf((float(v) - 1.0) / 9.0, 0.0, 1.0)

func _cloud_density_from_level(level_1_to_10: int) -> float:
	return lerpf(0.001, 0.045, _level01(level_1_to_10))
