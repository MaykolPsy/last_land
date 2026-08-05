extends Camera3D
class_name CameraFollow

@export var target: Node3D
@export var offset: Vector3 = Vector3(0, 3, -10)
@export var smooth_speed: float = 5.0
@export var look_at_height: float = 1.2

# 🎯 FOV SYSTEM
@export var normal_fov: float = 75.0
@export var boost_fov: float = 85.0
@export var fov_speed: float = 3.0

# 💥 SHAKE SYSTEM
@export var shake_decay: float = 4.0
var shake_strength: float = 0.0

# 🧱 COLLISION SYSTEM
@export_group("Collision")
@export var collision_mask: int = 1
@export var collision_radius: float = 0.35
@export var collision_margin: float = 0.2
@export var min_camera_distance: float = 2.0

var base_offset: Vector3

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	make_current()
	base_offset = offset
	fov = normal_fov

	if EventBus and EventBus.has_signal("camera_shake"):
		if not EventBus.camera_shake.is_connected(_on_camera_shake):
			EventBus.camera_shake.connect(_on_camera_shake)

func _exit_tree() -> void:
	if EventBus and EventBus.has_signal("camera_shake"):
		if EventBus.camera_shake.is_connected(_on_camera_shake):
			EventBus.camera_shake.disconnect(_on_camera_shake)

func _process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node3D
		if target == null:
			return

	_handle_follow(delta)
	_handle_fov(delta)
	_handle_shake(delta)

func _on_camera_shake(amount: float) -> void:
	add_shake(amount)

func _handle_follow(delta: float) -> void:
	var anchor := target.global_position + Vector3(0.0, look_at_height, 0.0)
	var desired := target.global_position + base_offset
	var safe_pos := _resolve_camera_collision(anchor, desired)

	global_position = global_position.lerp(safe_pos, clampf(smooth_speed * delta, 0.0, 1.0))
	look_at(anchor, Vector3.UP)

func _resolve_camera_collision(origin: Vector3, desired: Vector3) -> Vector3:
	var space := get_world_3d().direct_space_state

	var shape := SphereShape3D.new()
	shape.radius = collision_radius

	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = shape
	q.transform = Transform3D(Basis(), origin)
	q.motion = desired - origin
	q.collision_mask = collision_mask
	q.exclude = [target]
	q.collide_with_areas = false
	q.collide_with_bodies = true

	var result := space.cast_motion(q)
	if result.size() >= 2:
		var safe_t: float = result[0]
		if safe_t < 1.0:
			var dir := (desired - origin).normalized()
			var total := origin.distance_to(desired)
			var dist = max(total * safe_t - collision_margin, min_camera_distance)
			return origin + dir * dist

	return desired

func _handle_fov(delta: float) -> void:
	if target is PlayerControllerBase:
		var player := target as PlayerControllerBase
		var speed_factor: float = clampf(player.current_speed / maxf(player.max_speed, 0.001), 0.0, 1.0)
		var target_fov: float = lerpf(normal_fov, boost_fov, speed_factor)
		fov = lerpf(fov, target_fov, clampf(fov_speed * delta, 0.0, 1.0))

func _handle_shake(delta: float) -> void:
	if shake_strength <= 0.01:
		return

	shake_strength = lerpf(shake_strength, 0.0, clampf(shake_decay * delta, 0.0, 1.0))
	var shake_offset := Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0),
		0.0
	) * shake_strength

	global_position += shake_offset

func add_shake(amount: float) -> void:
	shake_strength = maxf(shake_strength, amount)
