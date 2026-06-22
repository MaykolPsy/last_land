extends Node3D

@export var parallax_factor: float = 0.1
@export var vertical_factor: float = 0.0
@export var smooth_speed: float = 5.0

var follow_camera: Camera3D

var _initial_offset: Vector3
var _target_position: Vector3

func _ready() -> void:
	_initial_offset = global_position

	# Buscar automáticamente la cámara activa
	follow_camera = get_viewport().get_camera_3d()

func _process(delta: float) -> void:
	if follow_camera == null:
		follow_camera = get_viewport().get_camera_3d()
		return

	_update_parallax(delta)

func _update_parallax(delta: float) -> void:
	var cam_pos := follow_camera.global_position

	var target_offset := Vector3(
		cam_pos.x * parallax_factor,
		cam_pos.y * vertical_factor,
		cam_pos.z * parallax_factor
	)

	_target_position = _initial_offset + target_offset

	global_position = global_position.lerp(
		_target_position,
		smooth_speed * delta
	)
