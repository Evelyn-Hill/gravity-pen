extends ProgressBar


func _ready() -> void:
	max_value = Zoo.ALIEN_EAT_INTERVAL
	Zoo.i.time_to_food.connect(on_time_to_food)

func on_time_to_food(_value : float) -> void:
	value = _value

