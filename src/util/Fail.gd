extends Label

const FAIL_TIME : float = 5.0
var fail_remaining_time : float = FAIL_TIME


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().get_parent().get_parent().get_parent().visible:
		fail_timer(delta)		

func fail_timer(delta) -> void:
	fail_remaining_time -= delta

	if fail_remaining_time <= 0:
		get_tree().quit()

