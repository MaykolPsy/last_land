extends PlayerControllerBase
class_name BoatController

@export_group("Movement")
@export var turn_speed: float = 2.5
@export var drag: float = 1.2
@export var max_turn_angle: float = 60.0
@export var min_x: float = -140.0
@export var max_x: float = 140.0
@export var fixed_start_y: float = 3.0

@export_group("Visual")
@export var visual_turn_strength: float = 0.4
@export var bob_amount: float = 0.05
@export var bob_speed: float = 2.0
@export var tilt_strength: float = 0.1

@export_group("Spawn Safety")
@export var spawn_invincibility_time: float = 1.0

@onready var hitbox: Area3D = $HitboxArea
@onready var hurtbox: Area3D = $HurtboxArea
@onready var visual_root: Node3D = $VisualRoot

var direction_input: float = 0.0
var base_visual_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	super._ready()
	process_mode = Node.PROCESS_MODE_PAUSABLE

	base_visual_y = visual_root.position.y
	global_position.y = fixed_start_y

	if hitbox and not hitbox.hit_detected.is_connected(_on_hit_detected):
		hitbox.hit_detected.connect(_on_hit_detected)

	if hurtbox and not hurtbox.near_miss.is_connected(_on_near_miss):
		hurtbox.near_miss.connect(_on_near_miss)

	_start_spawn_iframes()

func _start_spawn_iframes() -> void:
	is_invincible = true
	await get_tree().create_timer(spawn_invincibility_time).timeout
	is_invincible = false

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		velocity = Vector3.ZERO
		return

	super._physics_process(delta)
	_update_visuals(delta)
	_update_iframe_flash()

	var gs := GameStateManager.current_state
	var is_gameplay := gs == GameStateManager.GameState.STORY or gs == GameStateManager.GameState.INFINITE

	if is_gameplay and state != State.DEAD and not get_tree().paused:
		ScoreManager.add_distance(maxf(current_speed, 0.0) * delta)

func handle_input(_delta: float = 0.0) -> void:
	direction_input = Input.get_axis("move_right", "move_left")

func handle_movement(delta: float = 0.0) -> void:
	var rotation_change: float = direction_input * turn_speed * delta * 22.0
	rotation_degrees.y = clampf(rotation_degrees.y + rotation_change, -max_turn_angle, max_turn_angle)

	var forward: Vector3 = transform.basis.z
	velocity = forward * current_speed
	velocity.x -= velocity.x * drag * delta
	velocity.z -= velocity.z * drag * delta

	move_and_slide()

	global_position.x = clampf(global_position.x, min_x, max_x)
	global_position.y = fixed_start_y

func _update_iframe_flash() -> void:
	if not is_invincible:
		visual_root.visible = true
		return
	visual_root.visible = (int(Time.get_ticks_msec() / 80) % 2) == 0

func _update_visuals(delta: float) -> void:
	time_passed += delta
	visual_root.rotation.y = lerpf(visual_root.rotation.y, -direction_input * visual_turn_strength, 5.0 * delta)
	visual_root.rotation.z = lerpf(visual_root.rotation.z, -direction_input * tilt_strength, 3.0 * delta)
	visual_root.position.y = base_visual_y - abs(sin(time_passed * bob_speed)) * bob_amount

func _on_hit_detected(_area: Area3D) -> void:
	if state == State.DEAD or is_invincible:
		return

	EventBus.camera_shake.emit(3.0)
	die()

	if state == State.DEAD:
		current_speed = 0.0
		velocity = Vector3.ZERO
		direction_input = 0.0

func _on_near_miss(_area: Area3D) -> void:
	EventBus.camera_shake.emit(0.5)
