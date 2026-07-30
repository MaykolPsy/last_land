extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 3, -10)
@export var smooth_speed: float = 5.0


# 🎯 FOV SYSTEM
@export var normal_fov: float = 75.0
@export var boost_fov: float = 85.0
@export var fov_speed: float = 3.0

# 💥 SHAKE SYSTEM
var shake_strength: float = 0.0
var shake_decay: float = 4.0

var shake_intensity := 0.0

var base_offset: Vector3


func _on_camera_shake(amount: float):
	shake_intensity = amount
	print("SHAKE RECIBIDO: ", amount)
	add_shake(amount)
	
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	make_current()
	base_offset = offset
	fov = normal_fov
	EventBus.camera_shake.connect(_on_camera_shake)

	# opcional: conectar EventBus si lo tienes
	if Engine.has_singleton("EventBus"):
		pass

func _process(delta: float) -> void:
	if target == null:
		return

	_handle_follow(delta)
	_handle_fov(delta)
	_handle_shake(delta)

func _handle_follow(delta: float) -> void:
	var desired_position = target.global_position + base_offset

	global_position = global_position.lerp(
		desired_position,
		smooth_speed * delta
	)

	look_at(target.global_position, Vector3.UP)
	
func _handle_fov(delta: float) -> void:

	if target is PlayerControllerBase:

		var player := target as PlayerControllerBase

		var speed_factor = player.current_speed / player.max_speed

		var target_fov = lerp(
			normal_fov,
			boost_fov,
			speed_factor
		)

		fov = lerp(
			fov,
			target_fov,
			fov_speed * delta
		)

func _handle_shake(delta: float) -> void:
	if shake_strength > 0.01:
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)

		var offset = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			0
		) * shake_strength

		global_position += offset

func add_shake(amount: float) -> void:
	shake_strength = max(shake_strength, amount)
