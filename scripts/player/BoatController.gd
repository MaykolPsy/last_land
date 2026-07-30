extends PlayerControllerBase
class_name BoatController

@export var turn_speed: float = 2.5
@export var drag: float = 1.2
@export var visual_turn_strength: float = 0.4
@export var bob_amount: float = 0.05
@export var bob_speed: float = 2.0
@export var tilt_strength: float = 0.1
@export var paddle_speed: float = 6.0
@export var max_turn_angle: float = 60.0

@onready var hitbox = $HitboxArea
@onready var hurtbox = $HurtboxArea
@onready var visual_root: Node3D = $VisualRoot
@onready var paddles: Node3D = get_node("VisualRoot/boat-row-large2/boat-row-large/paddles")

var direction_input: float = 0.0
var base_visual_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	super._ready()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	base_visual_y = visual_root.position.y
	hitbox.hit_detected.connect(_on_hit_detected)
	hurtbox.near_miss.connect(_on_near_miss)
	global_position.y = 1.0

func _physics_process(delta: float) -> void:
	if Engine.get_process_frames() % 20 == 0:
		print("[Boat] physics running, state=", state, " speed=", current_speed, " paused=", get_tree().paused)
	if state == State.DEAD:
		return
	super._physics_process(delta)
	handle_visuals(delta)
	update_iframe_flash(delta)

func handle_input(_delta: float = 0.0) -> void:
	direction_input = Input.get_axis("move_right", "move_left")

func handle_movement(delta: float = 0.0) -> void:
	var rotation_change := direction_input * turn_speed * delta * 38.0
	rotation_degrees.y = clamp(rotation_degrees.y + rotation_change, -max_turn_angle, max_turn_angle)

	# CORREGIDO: forward real en Godot 3D
	var forward: Vector3 = transform.basis.z
	velocity = forward * current_speed

	velocity.x -= velocity.x * drag * delta
	velocity.z -= velocity.z * drag * delta

	move_and_slide()

	if Engine.get_process_frames() % 30 == 0:
		print("[Boat] speed=", current_speed, " vel=", velocity, " paused=", get_tree().paused)

func update_iframe_flash(_delta: float) -> void:
	if not is_invincible:
		visual_root.visible = true
		return
	visual_root.visible = int(Time.get_ticks_msec() / 80) % 2 == 0

func handle_visuals(delta: float) -> void:
	time_passed += delta

	visual_root.rotation.y = lerp(visual_root.rotation.y, -direction_input * visual_turn_strength, 5.0 * delta)
	visual_root.position.y = base_visual_y - abs(sin(time_passed * bob_speed)) * bob_amount
	visual_root.rotation.z = lerp(visual_root.rotation.z, -direction_input * tilt_strength, 3.0 * delta)

	var speed_factor := clampf(current_speed / base_speed, 0.05, 3.0)
	paddles.rotation.x = sin(time_passed * paddle_speed) * 0.4 * speed_factor
	paddles.rotation.y = sin(time_passed * paddle_speed) * 0.1 * speed_factor

	ScoreManager.add_distance(current_speed * delta)

func _on_hit_detected(_area) -> void:
	if state == State.DEAD or is_invincible:
		return
	EventBus.camera_shake.emit(3.0)
	await get_tree().create_timer(0.12).timeout
	die()

func _on_near_miss(area) -> void:
	print("NEAR MISS -> ", area.name)
	EventBus.camera_shake.emit(0.5)
