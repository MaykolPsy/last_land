extends Node3D
class_name SkyController

enum WeatherPreset { LIGHT, MID, HEAVY }

@export var preset: WeatherPreset = WeatherPreset.LIGHT
@export var environment_path: NodePath
@export var sun_path: NodePath

@export var enable_fog: bool = true
@export_range(0.0, 0.05, 0.0001) var fog_density_light: float = 0.003
@export_range(0.0, 0.05, 0.0001) var fog_density_mid: float = 0.006
@export_range(0.0, 0.05, 0.0001) var fog_density_heavy: float = 0.010

var env_node: WorldEnvironment = null
var sun_ref: DirectionalLight3D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	env_node = get_node_or_null(environment_path) as WorldEnvironment
	sun_ref = get_node_or_null(sun_path) as DirectionalLight3D

	_apply_preset()

func _apply_preset() -> void:
	var k: float = 0.35
	if preset == WeatherPreset.MID:
		k = 0.60
	elif preset == WeatherPreset.HEAVY:
		k = 0.85

	_apply_sky(k)
	_apply_sun(k)
	_apply_fog(k)

func _apply_sky(k: float) -> void:
	if env_node == null:
		return
	if env_node.environment == null:
		env_node.environment = Environment.new()

	var env: Environment = env_node.environment
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY

	var sky_mat: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	var sky: Sky = Sky.new()
	sky.sky_material = sky_mat
	env.sky = sky

	sky_mat.sky_top_color = Color.html("#7DB2DF").lerp(Color.html("#2C3A4E"), k)
	sky_mat.sky_horizon_color = Color.html("#D6ECFF").lerp(Color.html("#4E6078"), k)
	sky_mat.ground_horizon_color = Color.html("#7387A1").lerp(Color.html("#394B62"), k)
	sky_mat.ground_bottom_color = Color.html("#46566D").lerp(Color.html("#273344"), k)

	env.ambient_light_energy = lerpf(1.0, 0.65, k)

func _apply_sun(k: float) -> void:
	if sun_ref == null:
		return
	sun_ref.light_energy = lerpf(1.2, 0.8, k)
	sun_ref.light_color = Color(1.0, 0.96, 0.90).lerp(Color(0.82, 0.88, 0.95), k)

func _apply_fog(k: float) -> void:
	if env_node == null or env_node.environment == null:
		return

	var env: Environment = env_node.environment
	env.fog_enabled = enable_fog
	if not enable_fog:
		return

	var d: float = fog_density_light
	if preset == WeatherPreset.MID:
		d = fog_density_mid
	elif preset == WeatherPreset.HEAVY:
		d = fog_density_heavy

	env.fog_density = d
	env.fog_light_color = Color.html("#B7C6D9").lerp(Color.html("#6E7F95"), k)
	env.fog_light_energy = lerpf(1.0, 0.75, k)
	env.fog_aerial_perspective = lerpf(0.25, 0.6, k)
	env.volumetric_fog_enabled = false
