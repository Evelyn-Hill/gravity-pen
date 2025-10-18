class_name Alien
extends RigidBody2D

enum AlienType {
	BORING = 0,
	AWESOME = 1,
	EPIC = 2,
}

# --- Look up tables ---
const ALIEN_SCORES : Array[int] = [1, 3, 10]

const ALIEN_MOVE_SPEED : Array[float] = [50, 50, 125]

# Contain paths to alien visual scenes.
const ALIEN_VISUALS : Array[String] = [

]

const amplitudes : Array[float] = [
	5, 5, 5
]
const frequencies : Array[float] = [
	5, 5, 5
]


var time : float
var my_alien_type : AlienType = AlienType.BORING
var direction : Vector2 = Vector2(1, 0)
var released : bool = false

func _process(delta: float) -> void:
	if released:
		return

	time += delta
	var move_vector : Vector2 = Vector2(
		direction.x * ALIEN_MOVE_SPEED[my_alien_type] * delta,
		amplitudes[my_alien_type] * sin(time * frequencies[my_alien_type]),
	)

	position += move_vector

func release_rigidbody() -> void:
	const vertical_force := -1.5
	const horizontal_force_max := 1
	const horizontal_force_min := -1
	const impulse_muliplier = 200
	
	var random_vector : Vector2 = Vector2(randf_range(horizontal_force_min, horizontal_force_max), -1.5)
	apply_central_impulse(random_vector * impulse_muliplier)
	gravity_scale = 1.0
	released = true
