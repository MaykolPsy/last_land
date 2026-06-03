extends CharacterBody3D
class_name PlayerControllerBase

enum State { IDLE, MOVING, BOOSTING, SHIELDED, DEAD }

# --- SPEED CORE ---
@export var base_speed: float = 10.0
@export var max_speed: float = 30.0
@export var acceleration: float = 0.5
@export var bonus_per_item: float = 0.3       # cuánto sube por ítem
@export var max_item_bonus: float = 8.0        # tope del bonus de ítems

var current_speed: float = 0.0
var speed_progress: float = 0.0               # sube con el tiempo (recorrido)
var item_speed_bonus: float = 0.0             # sube al recolectar ítems
var state: State = State.IDLE

func _ready():
	current_speed = base_speed

func _physics_process(delta):
	if state == State.DEAD:
		return
	handle_speed(delta)
	handle_input(delta)
	handle_movement(delta)

func handle_input(delta): pass        # override en hijos

func handle_movement(delta):
	var forward = -transform.basis.z
	velocity = forward * current_speed
	move_and_slide()

func handle_speed(delta):
	speed_progress += acceleration * delta
	var total = base_speed + speed_progress + item_speed_bonus
	current_speed = clamp(total, base_speed, max_speed)
	print("speed_progress:", speed_progress, " current_speed:", current_speed)

# Llamar esto desde el hijo cuando se recoge un ítem
func add_item_bonus():
	item_speed_bonus = clamp(item_speed_bonus + bonus_per_item, 0.0, max_item_bonus)

func set_state(new_state: State):
	state = new_state
