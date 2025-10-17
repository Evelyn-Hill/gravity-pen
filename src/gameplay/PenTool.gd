class_name PenTool
extends Area2D

var last_clicked_position: Vector2 

var line_points : PackedVector2Array

@onready var collision_polygon : CollisionPolygon2D = get_node("CollisionPolygon2D")
@onready var ray1 : RayCast2D = get_node("Ray1")
@onready var ray2 : RayCast2D = get_node("Ray2")


func _process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		last_clicked_position = get_viewport().get_mouse_position()
		last_clicked_position = last_clicked_position - (get_viewport_rect().size * 0.5)
		line_points.append(last_clicked_position)
	
	#if Input.is_action_released("click"):	
	else:
		line_points = cull_points(line_points)

		if line_points.size() < 4:
			return

		ray1.position = line_points[0] 
		ray1.target_position = line_points[2] - line_points[0]

		ray2.position = line_points[1]
		ray2.target_position = line_points[3] - line_points[1]

		if ray1.is_colliding() && ray2.is_colliding():	
			print(ray1.get_collision_point())
			print(ray2.get_collision_point())
			print(type_string(typeof(ray1.get_collider())))
			var node: Node2D = ray1.get_collider() as Node2D
			print(node.name)
			print("Inside")
		
		line_points.clear()

	queue_redraw()

func _draw() -> void:
	if !line_points.size() < 3:
		draw_polyline(line_points, Color.WHITE, 7.0)

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
