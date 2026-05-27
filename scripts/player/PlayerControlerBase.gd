extends CharacterBody3D

class_name PlayerController

enum State {
	IDLE,
	MOVING,
	BOOSTING,
	SHIELDED,
	DEAD
}

@export var base_speed: float = 10.0
@export var max_speed: float = 25.0
@export var acceleration: float = 5.0

var current_speed: float = 0.0
var state: State = State.IDLE

func _ready():
	current_speed = base_speed

func _physics_process(delta):
	handle_input(delta)
	handle_movement(delta)

func handle_input(delta):
	# abstracto (lo usan los hijos)
	pass

func handle_movement(delta):
	if state == State.DEAD:
		return
	
	velocity = Vector3.FORWARD * current_speed
	move_and_slide()

func set_state(new_state: State):
	state = new_state
