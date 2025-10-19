extends Sprite2D



func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = ((event.position - get_viewport_rect().size / 2) / Main.camera.zoom) + Main.camera.position
	
	if event.is_action_pressed("click"):
		frame = 1
	else:
		frame = 0
