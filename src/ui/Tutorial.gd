class_name Tutorial
extends CanvasLayer

static var i

signal do_continue()

signal wait_over_signal()

var main : Main
var zoo : Zoo
var plinko : PlinkoBoard

const TEXT_SCROLL_TIME : float = 1.2



enum TutorialState {
	IDLE,
	LOADING,
	RUNNING,
	WAITING,
	ACTIONING,
}

var my_tutorial_state : TutorialState = TutorialState.IDLE

var tutorial_index : int = -1

var visible_node : Node2D

@export var scene : TutorialScene

var move_on := false

var wait_over : bool = false

func _enter_tree() -> void:
	i = self

func TickInput(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if my_tutorial_state == TutorialState.IDLE:
			do_continue.emit() 


func start_tutorial() -> void:
	next_scene()	

func next_scene() -> void:
	if tutorial_index + 1 == scene.texts.size():
		self.visible = false
		Main.i.tidy_game_state()
		return

	my_tutorial_state = TutorialState.LOADING
	if visible_node:
		visible_node.hide()
	tutorial_index += 1
	run_scene(tutorial_index)		

func run_scene(index : int) -> void:
	check_action()
	move_on = false
	%TalkSprite.texture = scene.sprites[index]
	%TalkSprite.flip_h = scene.flip_sprite[index]

	%Text.visible_ratio = 0
	%Text.text = scene.texts[index]

	await show_box()

	SFXPlayer.i.play(SFXPlayer.SFX.TYPING)
	var tween := get_tree().create_tween()	
	tween.tween_property(%Text, "visible_ratio", 1, TEXT_SCROLL_TIME)
	await tween.finished

	check_node()
	check_wait()
	await wait()
	if move_on:
		my_tutorial_state = TutorialState.IDLE
		await hide_box()
		next_scene()
	else:
		my_tutorial_state = TutorialState.IDLE
		await do_continue
		await hide_box()
		next_scene()

func check_node() -> void:
	if scene.node_visible.has(tutorial_index):
		visible_node = get_node(scene.node_visible[tutorial_index])
		visible_node.show()

func check_wait():
	if scene.wait_moments.has(tutorial_index):
		my_tutorial_state = TutorialState.WAITING
		%Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		%Control.modulate = Color(1, 1, 1, 0.9)
		wait_over = false
		SignalBus.connect(scene.wait_moments[tutorial_index], func(): 
			my_tutorial_state = TutorialState.IDLE
			wait_over_signal.emit()
		)
	else:
		wait_over = true

func wait() -> bool:
	if wait_over:
		return true

	print("Waiting...")
	await wait_over_signal
	move_on = true
	my_tutorial_state = TutorialState.IDLE
	%Control.mouse_filter = Control.MOUSE_FILTER_STOP
	%Control.modulate = Color(1, 1, 1, 1)
	await get_tree().create_timer(0.01).timeout
	return true

func check_action() -> void:	
	if scene.commands.has(tutorial_index - 1):
		SignalBus.emit_signal(scene.commands[tutorial_index - 1])

func show_box() -> bool:
	const ANIM_TIME : float = 0.3
	const POSITION_OFFSET : Vector2 = Vector2(0, -40)

	%TutorialContainer.position -= POSITION_OFFSET

	var t  := get_tree().create_tween()
	t.tween_property(%TutorialContainer, "modulate", Color.WHITE, ANIM_TIME)
	t.parallel().tween_property(%TutorialContainer, "position", %TutorialContainer.position + POSITION_OFFSET, ANIM_TIME)
	await t.finished
	return true


func hide_box() -> bool:
	const ANIM_TIME : float = 0.3
	const POSITION_OFFSET : Vector2 = Vector2(0, -40)

	var t  := get_tree().create_tween()
	t.tween_property(%TutorialContainer, "modulate", Color.TRANSPARENT, ANIM_TIME)
	t.parallel().tween_property(%TutorialContainer, "position", %TutorialContainer.position - POSITION_OFFSET, ANIM_TIME)	
	await t.finished
	%TutorialContainer.position = Vector2(979, 611)
	return true
