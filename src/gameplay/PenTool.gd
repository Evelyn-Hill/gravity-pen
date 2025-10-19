class_name PenTool
extends Node2D

enum MouseState {
	NONE,
	CHARGING,
	COOLDOWN
}

var is_selecting : bool = false
var start_position: Vector2
var radius : float = 50

var select_time : float = 2.5
var select_timer : float = 0.0

var selection_frames : Array[Array]

var circle_color : Color = Color(1, 1, 1, 0.05)
var circle_outline_color : Color = Color(0, 1, 0, 0.5)

var arc_inside_color: Color = Color(1, 0, 0, 1)
var inside_radius : float = 0

var attack_enabled : bool = false

var circle_animation_progress : float = 0

const HOLD_TIME : float = 2.5
const COOLDOWN_TIME : float = 2.5

var attack_time : float = HOLD_TIME
var cooldown : float = COOLDOWN_TIME

var my_mouse_state : MouseState = MouseState.NONE

var focus_node : Node2D = null

@export var reverse_audio_stream : AudioStream
var rev_audio_duration : float

enum PlinkoAnimEnum {
	WAITING,
	FIRST_BEAT,
	SECOND_BEAT,
	RESET,
}

var my_plinko_state : PlinkoAnimEnum = PlinkoAnimEnum.WAITING


func _ready() -> void:
	rev_audio_duration = reverse_audio_stream.get_length()

func UpdateInput(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		start_position = ((event.position - get_viewport_rect().size / 2) / Main.camera.zoom) + Main.camera.position

		if start_position.y < -400:
			attack_enabled = false
		else:
			attack_enabled = true


func find_objects_in_circle() -> Array[Node]:
	var result : Array[Node]
	var center = start_position

	for item in get_tree().get_nodes_in_group("selectable"):
		if item.global_position.distance_to(center) <= radius:
			result.append(item)
	
	return result

func Tick(delta: float) -> void:
	if my_mouse_state == MouseState.COOLDOWN:
		cooldown_timer(delta)

	animate_plinko(delta)										

	if Input.is_action_pressed("click") and my_mouse_state != MouseState.COOLDOWN:
		attack_time -= delta
		selection_frames.append(find_objects_in_circle())	

		animate_cirlce(delta)

		if !%hold.playing:
			%hold.play()

		if attack_time <= rev_audio_duration:
			if !%build.playing:
				%build.play()			
		
		if attack_time <= HOLD_TIME / 1.5 and my_plinko_state == PlinkoAnimEnum.WAITING:
			my_plinko_state = PlinkoAnimEnum.FIRST_BEAT
		

		if attack_time <= 0:
			%fire.play()	
			Main.i.shake_camera()	
			%Particles.emitting = true
			var frames : Dictionary[Node, int] = evaluate_selection_frames()
			for node in frames:
				if frames[node] > frames.size() / 2:
					if node is Alien:
						node.release_rigidbody()
			reset_attack(true)
	else:
		if attack_time < 1.5:
			reset_attack(true)
			%cancel.play()
			Main.i.cancel_camera()
		reset_attack(false)		
					
	queue_redraw()

func reset_attack(cooldown : bool) -> void:
	%hold.stop()
	%build.stop()
	circle_animation_progress = 0
	attack_time = HOLD_TIME
	my_plinko_state = PlinkoAnimEnum.WAITING
	%Particles.emitting = false
	if selection_frames.size() > 0:
		selection_frames.clear()
	circle_color = Color(1, 1, 1, 0.05)
	if cooldown:
		my_mouse_state = MouseState.COOLDOWN

		
func BackgroundTick(delta : float) -> void:	
	if Main.my_game_view == Main.GameView.ZOO:
		stop_audio()

func cooldown_timer(delta: float) -> void:
	cooldown -= delta
	
	circle_outline_color = circle_outline_color.lerp(Color(0, 1, 0, 0.5), (1 - cooldown / COOLDOWN_TIME) * delta)			

	if cooldown <= 0:
		my_mouse_state = MouseState.NONE
		cooldown = COOLDOWN_TIME
		SFXPlayer.i.play(SFXPlayer.SFX.BEAM_READY)		

func evaluate_selection_frames() -> Dictionary[Node, int]:
	var result : Dictionary[Node, int] 

	for item in selection_frames:
		for node : Node2D in item:
			if !node.is_inside_tree():
				continue
			result.get_or_add(node, 0)
			result[node] += 1

	return result


func animate_cirlce(delta : float) -> void:
	circle_animation_progress += delta / HOLD_TIME
	circle_color = lerp(circle_color, Color(1, 0, 0.1, circle_animation_progress), circle_animation_progress)
	circle_outline_color = lerp(circle_outline_color, Color(1, 0, 0, 1), circle_animation_progress)

func _draw() -> void:
	if !attack_enabled:
		return

	var center = start_position
	# Optional: Draw a translucent, filled circle
	
	draw_circle(center, radius, circle_color)
	draw_arc(center, inside_radius, 0, PI * 2, 64, arc_inside_color, 2.0)

	# Draw a yellow outline
	draw_arc(center, radius, 0, PI * 2, 64, circle_outline_color, 4.0)
		

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

func update_child_positions() -> void:
	for child in get_children():
		child.position = position

func stop_audio() -> void:
	for child in get_children():
		child.stop()

func animate_plinko(delta) -> void:
	const PLINKO_SCALE_BEAT : Vector2 = Vector2(2, 2)

	match my_plinko_state:
		PlinkoAnimEnum.WAITING:
			reset_plinko(delta)
		PlinkoAnimEnum.FIRST_BEAT:			
			Main.camera.position = Main.camera.position.lerp(start_position, 0.99 * delta * 1)
			Main.camera.zoom = Main.camera.zoom.lerp(PLINKO_SCALE_BEAT, 0.99 * delta * 2)	

	
func reset_plinko(delta) -> void:
	Main.camera.position = Main.camera.position.lerp(Vector2.ZERO, 1 * delta * 5)
	Main.camera.zoom = Main.camera.zoom.lerp(Vector2(1, 1), 1 * delta * 5)	
