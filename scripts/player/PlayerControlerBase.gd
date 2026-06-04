extends CharacterBody3D
class_name PlayerControllerBase

enum State { IDLE, MOVING, BOOSTING, SHIELDED, DEAD }

@export var base_speed: float = 10.0
@export var max_speed: float = 30.0
@export var acceleration: float = 0.5
@export var bonus_per_item: float = 0.3
@export var max_item_bonus: float = 8.0

var current_speed: float = 0.0
var speed_progress: float = 0.0
var item_speed_bonus: float = 0.0
var state: State = State.IDLE

# IFrames
var iframe_timer: float = 10.0
var is_invincible: bool = false

func _ready() -> void:
	current_speed = base_speed

func _physics_process(delta: float) -> void:
	update_iframes(delta)

	if state == State.DEAD:
		return

	handle_speed(delta)
	handle_input(delta)
	handle_movement(delta)

func handle_input(_delta: float) -> void:
	pass

func handle_movement(_delta: float) -> void:
	var forward = -transform.basis.z
	velocity = forward * current_speed
	move_and_slide()

func handle_speed(delta: float) -> void:
	speed_progress += acceleration * delta

	var total := base_speed + speed_progress + item_speed_bonus

	current_speed = clamp(
		total,
		base_speed,
		max_speed
	)

func add_item_bonus() -> void:
	item_speed_bonus = clamp(
		item_speed_bonus + bonus_per_item,
		0.0,
		max_item_bonus
	)

func set_state(new_state: State) -> void:
	state = new_state

func die() -> void:
	if state == State.DEAD:
		return

	set_state(State.DEAD)

	print("PLAYER DIED")

	EventBus.player_died.emit()

func update_iframes(delta: float) -> void:

	if not is_invincible:
		return

	iframe_timer -= delta

	if iframe_timer <= 0.0:
		iframe_timer = 0.0
		is_invincible = false

func start_iframes(duration: float = 0.5) -> void:
	is_invincible = true
	iframe_timer = duration
