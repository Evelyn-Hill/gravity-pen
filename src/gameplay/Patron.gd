class_name Patron
extends PathFollow2D

@onready var path : Path2D = get_parent() as Path2D
@export var path_speed : float = 0.001

enum ProgressState {
	NONE,
	PROGRESSING,
	PAUSED,	
	FINISHED,
}

var my_progress_state : ProgressState = ProgressState.PROGRESSING

const MIN_THINK_TIME : float = 3.0
const MAX_THINK_TIME : float = 7.0

var think_points : Array[float]

@export var possible_shirt_colors : Array[Color]

func _ready() -> void:
	%Shirt.modulate = possible_shirt_colors.pick_random()
	var think_question : float = randf_range(0, 100)
	if think_question < 75:
		generate_think_points()

func Tick(delta: float) -> void:
	if progress_ratio >= 1:
		my_progress_state = ProgressState.FINISHED
		Zoo.i.remove_patron(self)	
		self.queue_free()

	if my_progress_state == ProgressState.PROGRESSING:
		for think_point in think_points:
			if is_equal_approx(progress_ratio / 100, think_point / 100):
				think()
				return
		progress_ratio += path_speed

func generate_think_points() -> void:
	var think_count : int = randi_range(1, 5)

	for i in range(think_count):
		think_points.append(randf_range(0.1, 1.0))

func think() -> void:
	my_progress_state = ProgressState.PAUSED
	await get_tree().create_timer(randf_range(MIN_THINK_TIME, MAX_THINK_TIME)).timeout
	progress_ratio += path_speed
	my_progress_state = ProgressState.PROGRESSING
