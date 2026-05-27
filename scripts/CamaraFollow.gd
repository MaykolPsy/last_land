extends Camera3D

@export var target: Node3D
@export var offset: Vector3 = Vector3(4, 3, 10)
@export var smooth_speed: float = 5.0

func _ready() -> void:
	make_current()

func _process(delta: float) -> void:
	if target == null:
		return

	var desired_position = target.global_position + offset

	# Movimiento suave
	global_position = global_position.lerp(desired_position, smooth_speed * delta)

	# Mirar al target
	look_at(target.global_position, Vector3.UP)
