extends CharacterBody3D
class_name BoatController

@export var base_speed: float = 8.0
@export var turn_speed: float = 2.5
@export var acceleration: float = 3.0
@export var drag: float = 1.2
@export var bob_amount: float = 0.05
@export var bob_speed: float = 2.0

var current_speed: float = 0.0
var direction_input: float = 0.0
var base_y: float

func _ready() -> void:
	base_y = position.y

func _physics_process(delta: float) -> void:
	handle_input()
	handle_movement(delta)
	handle_bobbing(delta)

func handle_input() -> void:
	direction_input = Input.get_axis("move_right", "move_left")

func handle_movement(delta: float) -> void:
	current_speed = lerp(current_speed, base_speed, acceleration * delta)

	var forward = -transform.basis.z

	rotate_y(direction_input * turn_speed * delta)

	velocity = forward * current_speed

	velocity.x -= velocity.x * drag * delta
	velocity.z -= velocity.z * drag * delta

	move_and_slide()

func handle_bobbing(delta: float) -> void:
	var bob = sin(Time.get_ticks_msec() * 0.002 * bob_speed) * bob_amount
	position.y = base_y + bob
