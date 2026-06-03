extends CharacterBody3D
class_name BoatController
@export var base_speed: float = 8.0
@export var turn_speed: float = 2.5

@export var acceleration: float = 3.0
@export var drag: float = 1.2

@export var visual_turn_strength: float = 0.4
@export var bob_amount: float = 0.05

@export var bob_speed: float = 2.0
@export var tilt_strength: float = 0.1

@export var paddle_strength: float = 0.4
@export var paddle_speed: float = 6.0

@onready var hitbox = $HitboxArea
@onready var hurtbox = $HurtboxArea


var current_speed: float = 0.0
var direction_input: float = 0.0

var base_visual_y: float = 0.0
var time_passed: float = 0.0


@onready var visual_root: Node3D = $VisualRoot
@onready var paddles: Node3D = get_node("VisualRoot/boat-row-large2/boat-row-large/paddles")


func _ready() -> void:
	base_visual_y = visual_root.position.y
	hitbox.hit_detected.connect(_on_hit_detected)
	hurtbox.near_miss.connect(_on_near_miss)
	
	
func _physics_process(delta: float) -> void:
	handle_input()
	handle_movement(delta)
	handle_visuals(delta)
	
	
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
	
	

func handle_visuals(delta: float) -> void:
	time_passed += delta
	# giro visual del barco
	visual_root.rotation.y = lerp(
		visual_root.rotation.y,
		-direction_input * visual_turn_strength,
		5.0 * delta
	)
	# bobbing
	visual_root.position.y = base_visual_y - abs(sin(time_passed * bob_speed)) * bob_amount
	# ladeo del barco
	visual_root.rotation.z = lerp(
		visual_root.rotation.z,
		-direction_input * tilt_strength,
		3.0 * delta
	)
	var speed_factor = clamp(current_speed / base_speed, 0.05, 3)
	paddles.rotation.x = sin(time_passed * paddle_speed) * 0.4 * speed_factor
	paddles.rotation.y = sin(time_passed * paddle_speed) * 0.1 * speed_factor
	# animación de remos desactivada por ahora
	# paddles.rotation.x = sin(time_passed * paddle_speed) * paddle_strength * speed_factor

func _on_hit_detected(area):
	print("COLLISION WITH: ", area.name)

func _on_near_miss(area):
	print("NEAR MISS -> ", area.name)
