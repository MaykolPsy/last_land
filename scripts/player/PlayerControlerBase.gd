extends CharacterBody3D
class_name PlayerControllerBase

enum State { IDLE, MOVING, BOOSTING, SHIELDED, DEAD }

@export var base_speed: float = 10.0
@export var max_speed: float = 30.0
@export var acceleration: float = 0.5
@export var bonus_per_item: float = 0.3
@export var max_item_bonus: float = 8.0
@export var turbo_speed_bonus: float = 8.0

var current_speed: float = 0.0
var speed_progress: float = 0.0
var item_speed_bonus: float = 0.0
var turbo_bonus: float = 0.0

var shield_active: bool = false
var state: State = State.IDLE

var iframe_timer: float = 0.0
var is_invincible: bool = false

var _turbo_token: int = 0
var _shield_token: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	current_speed = base_speed
	set_state(State.MOVING)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		velocity = Vector3.ZERO
		return

	update_iframes(delta)
	handle_speed(delta)
	handle_input(delta)
	handle_movement(delta)

func handle_input(_delta: float) -> void:
	pass

func handle_movement(_delta: float) -> void:
	var forward := -transform.basis.z
	velocity = forward * current_speed
	move_and_slide()

func handle_speed(delta: float) -> void:
	speed_progress += acceleration * delta
	var total := base_speed + speed_progress + item_speed_bonus + turbo_bonus
	current_speed = clamp(total, base_speed, max_speed)

func add_item_bonus() -> void:
	item_speed_bonus = clamp(item_speed_bonus + bonus_per_item, 0.0, max_item_bonus)

func activate_turbo(duration: float) -> void:
	_turbo_token += 1
	var my_token := _turbo_token

	turbo_bonus = turbo_speed_bonus
	if state != State.SHIELDED and state != State.DEAD:
		set_state(State.BOOSTING)

	await get_tree().create_timer(duration).timeout
	if !is_inside_tree() or state == State.DEAD:
		return
	if my_token != _turbo_token:
		return

	turbo_bonus = 0.0
	if shield_active:
		set_state(State.SHIELDED)
	else:
		set_state(State.MOVING)

func activate_shield(duration: float) -> void:
	_shield_token += 1
	var my_token := _shield_token

	shield_active = true
	EventBus.shield_changed.emit(true)
	if state != State.DEAD:
		set_state(State.SHIELDED)

	await get_tree().create_timer(duration).timeout
	if !is_inside_tree() or state == State.DEAD:
		return
	if my_token != _shield_token:
		return
	if not shield_active:
		return

	shield_active = false
	EventBus.shield_changed.emit(false)

	if turbo_bonus > 0.0:
		set_state(State.BOOSTING)
	else:
		set_state(State.MOVING)

func set_state(new_state: State) -> void:
	state = new_state

func die() -> void:
	if is_invincible:
		return

	# CON SHIELD: bloquea daño y NO muere
	if shield_active:
		start_iframes(0.2)
		return

	if state == State.DEAD:
		return

	set_state(State.DEAD)
	current_speed = 0.0
	velocity = Vector3.ZERO
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
