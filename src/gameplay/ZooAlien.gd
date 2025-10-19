class_name ZooAlien
extends Sprite2D

enum State {
	THINKING,
	WANDERING,
}

@onready var anim : AnimationPlayer = %Animation


var thinking_time : float = 7.0

@export var type : Alien.AlienType

const MIN_THINKING_TIME : float = 5.0
const MAX_THINKING_TIME : float = 20.0

const SPEED = 35

const THINK_CHECK_INTERVAL : float = 5.0
const THINK_PROBABILITY : int = 35

var think_check_time : float = THINK_CHECK_INTERVAL
var think_time : float

var my_state : State = State.WANDERING

var wander_direction : Vector2

func _ready() -> void:
	fade_in()
	start_wander()


func Tick(delta : float) -> void:
	match my_state:
		State.WANDERING:
			wander(delta)
			think_check_timer(delta)
		State.THINKING:
			think(delta)

func wander(delta : float) -> void:
	if !get_parent().wander_rect.has_point(position + wander_direction * SPEED * delta):
		start_wander()
		return

	position += wander_direction * SPEED * delta

func start_think() -> void:
	think_time = randf_range(MIN_THINKING_TIME, MAX_THINKING_TIME)				
	my_state = State.THINKING
	%AnimationTree.set("parameters/blend_position", Vector2.ZERO)

func start_wander() -> void:
	var random_x : float = randf_range(-1, 1)
	var random_y : float = randf_range(-1, 1)
	wander_direction = Vector2(random_x, random_y)
	%AnimationTree.set("parameters/blend_position", wander_direction)

func think(delta : float) -> void:
	think_time -= delta

	if think_time <= 0:
		my_state = State.WANDERING
	
func think_check_timer(delta : float) -> void:		
	think_check_time -= delta 
	
	if think_check_time <= 0:
		var success : int = randi_range(0, 100)
		if success < THINK_PROBABILITY:
			start_think()
		think_check_time = THINK_CHECK_INTERVAL

func fade_in() -> void:
	self.modulate = Color.TRANSPARENT
	var tween : Tween = get_tree().create_tween()
	const TWEEN_TIME : float = 2.5
	tween.tween_property(self, "modulate", Color.WHITE, TWEEN_TIME)
