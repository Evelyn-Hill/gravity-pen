class_name PenTool
extends Node2D

var is_selecting : bool = false
var start_position: Vector2
var radius : float = 50

var select_time : float = 2.5
var select_timer : float = 0.0

var selection_frames : Array[Array]

var circle_color : Color = Color(1, 1, 1, 0.2)

var arc_inside_color: Color = Color(1, 0, 0, 1)
var inside_radius : float = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		start_position = event.position - (get_viewport_rect().size * 0.5)

	if event.is_action_pressed("click") and is_selecting == false:
		animate_cirlce()
		is_selecting = true

func find_objects_in_circle() -> Array[Node]:
	var result : Array[Node]
	var center = start_position

	for item in get_tree().get_nodes_in_group("selectable"):
		if item.global_position.distance_to(center) <= radius:
			result.append(item)
	
	return result

func _process(delta: float) -> void:
	if is_selecting:
		select_timer += delta
		selection_frames.append(find_objects_in_circle())
		if select_timer > select_time:	
			is_selecting = false
			select_timer = 0
			var result = find_selected_node(evaluate_selection_frames())
			if result != null:
				if result is Alien:
					result.release_rigidbody()
			selection_frames.clear()
	queue_redraw()

func evaluate_selection_frames() -> Dictionary[Node, int]:
	var result : Dictionary[Node, int] 

	for item in selection_frames:
		for node : Node2D in item:
			result.get_or_add(node, 0)
			result[node] += 1

	return result

func find_selected_node(data: Dictionary[Node, int]) -> Node:

	var highest_count : int = 0
	var best_node : Node = null

	for item : Node in data:
		if data[item] > highest_count:
			highest_count = data[item]
			best_node = item

	if highest_count > selection_frames.size() / 2:	
		return best_node
	else:
		return null


func animate_cirlce() -> void:
	animate_arc(select_time)
	var tween : Tween = get_tree().create_tween().parallel()
	tween.tween_property(self, "circle_color", Color(1, 0, 0, 0.2), select_time)	
	tween.finished.connect(func(): circle_color = Color(1, 1, 1, 0.2), CONNECT_ONE_SHOT)

	pass

func animate_arc(time : float) -> void:
	if time < 0.001:
		return

	var new_time : float = time / 2
	var tween2 : Tween = get_tree().create_tween()
	tween2.tween_property(self, "inside_radius", radius, new_time)
	tween2.finished.connect(func(): 
		inside_radius = 0.0
		animate_arc(new_time), CONNECT_ONE_SHOT)

func _draw() -> void:
	var center = start_position
		# Optional: Draw a translucent, filled circle
	draw_circle(center, radius, circle_color)
	draw_arc(center, inside_radius, 0, PI * 2, 64, arc_inside_color, 2.0)

	# Draw a yellow outline
	draw_arc(center, radius, 0, PI * 2, 64, Color.RED, 2.0)
		

func cull_points(packed_array: PackedVector2Array) -> PackedVector2Array:
	if !packed_array.size() > 4:
		return packed_array

	var count = 0
	var result : PackedVector2Array	
		
	for point in packed_array:
		if count == 0 || count % (packed_array.size() / 4) == 0:
			result.append(point)	
		count += 1	
	if result.size() > 4:
		result.remove_at(result.size() - 1)

	return result



func find_inside_node() -> void:
	pass
