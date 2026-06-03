extends PlayerControllerBase      # <-- CAMBIO CLAVE
class_name BoatController

@export var turn_speed: float = 2.5
@export var drag: float = 1.2
@export var visual_turn_strength: float = 0.4
@export var bob_amount: float = 0.05
@export var bob_speed: float = 2.0
@export var tilt_strength: float = 0.1
@export var paddle_speed: float = 6.0

@onready var hitbox = $HitboxArea
@onready var hurtbox = $HurtboxArea
@onready var visual_root: Node3D = $VisualRoot
@onready var paddles: Node3D = get_node("VisualRoot/boat-row-large2/boat-row-large/paddles")

var direction_input: float = 0.0
var base_visual_y: float = 0.0
var time_passed: float = 0.0

func _ready() -> void:
	super._ready()    # inicializa current_speed = base_speed
	base_visual_y = visual_root.position.y
	hitbox.hit_detected.connect(_on_hit_detected)
	hurtbox.near_miss.connect(_on_near_miss)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	super._physics_process(delta)   # llama handle_speed + handle_input + handle_movement
	handle_visuals(delta)
	print(delta)

# VehicleBase llama esto automáticamente
func handle_input(_delta: float = 0.0) -> void:
	direction_input = Input.get_axis("move_right", "move_left")

# VehicleBase llama esto automáticamente
func handle_movement(_delta: float = 0.0) -> void:
	rotate_y(direction_input * turn_speed * _delta)
	var forward = -transform.basis.z
	velocity = forward * current_speed
	velocity.x -= velocity.x * drag * _delta
	velocity.z -= velocity.z * drag * _delta
	move_and_slide()

func handle_visuals(delta: float) -> void:
	time_passed += delta
	visual_root.rotation.y = lerp(visual_root.rotation.y, -direction_input * visual_turn_strength, 5.0 * delta)
	visual_root.position.y = base_visual_y - abs(sin(time_passed * bob_speed)) * bob_amount
	visual_root.rotation.z = lerp(visual_root.rotation.z, -direction_input * tilt_strength, 3.0 * delta)
	var speed_factor = clamp(current_speed / base_speed, 0.05, 3.0)
	paddles.rotation.x = sin(time_passed * paddle_speed) * 0.4 * speed_factor
	paddles.rotation.y = sin(time_passed * paddle_speed) * 0.1 * speed_factor

func _on_hit_detected(_area):
	if state == State.DEAD:
		return
	die()

func _on_near_miss(area):
	print("NEAR MISS -> ", area.name)

func die() -> void:
	set_state(State.DEAD)
	print("PLAYER DIED")
	EventBus.player_died.emit()
