class_name Main
extends Node2D

enum GameView {
	MENU,
	PLINKO,
	ZOO,
	PAUSE,		
	TUTORIAL,
	FAIL,
}

static var my_game_view : GameView = GameView.MENU

static var game_state : GameState = GameState.new()

@export var plinko : PlinkoBoard
@export var zoo : Zoo

static var camera : Camera2D

var pre_pause_game_view : GameView 

static var i

func _enter_tree() -> void:
	i = self
	print('Enter')

func _ready() -> void:
	print("Hello, Gravity Pen")
	SignalBus.swap_view.connect(swap_view)
	camera = get_node("Camera2D")
	var buttons = find_nodes_of_type(self, "Button")
	for b : Button in buttons:
		b.mouse_entered.connect(button_hover)
		b.pressed.connect(button_click.bind(b))

	for b : TextureButton in find_nodes_of_type(self, "TextureButton"):
		b.mouse_entered.connect(button_hover)
		b.pressed.connect(func(): SFXPlayer.i.play(SFXPlayer.SFX.COIN))

	%Embark.pressed.connect(func(): start_game())
	%Disembark.pressed.connect(func(): get_tree().quit())
	%Return.pressed.connect(func(): 
		%PauseMenu.hide()
		my_game_view = pre_pause_game_view
	)



func start_game() -> void:
	if my_game_view != GameView.MENU:
		return
		
	my_game_view = GameView.TUTORIAL
	%CameraShake.play("MenuOut")
	MusicPlayer.fade(MusicPlayer.Tracks.Gameplay)
	await %CameraShake.animation_finished
	plinko.Start()	
	await get_tree().create_timer(3.5).timeout
	Tutorial.i.start_tutorial()

func tidy_game_state() -> void:
	my_game_view = GameView.ZOO	

func _process(delta: float) -> void:
	if my_game_view == GameView.FAIL:
		%GameOver.visible= true
		return

	match my_game_view:
		GameView.MENU:
			MouseParralax.i.Tick(delta)
		GameView.PLINKO:
			plinko.Tick(delta)
			zoo.BackgroundTick(delta)
			plinko.BackgroundTick(delta)
		GameView.ZOO:
			zoo.Tick(delta)
			zoo.BackgroundTick(delta)
			plinko.BackgroundTick(delta)
		GameView.TUTORIAL:
			plinko.Tick(delta)
			zoo.Tick(delta)
			plinko.BackgroundTick(delta)
			zoo.BackgroundTick(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if my_game_view == GameView.TUTORIAL or my_game_view == GameView.MENU or my_game_view == GameView.FAIL:
			return
			
		if my_game_view == GameView.PAUSE:
			%PauseMenu.hide()
			my_game_view == pre_pause_game_view
		else:
			pre_pause_game_view = my_game_view
			my_game_view = GameView.PAUSE
			%PauseMenu.show()
		return

	match my_game_view:
		GameView.MENU:
			MouseParralax.i.UpdateInput(event)
		GameView.PLINKO:
			plinko.UpdateInput(event)
		GameView.ZOO:
			zoo.UpdateInput(event)	
		GameView.TUTORIAL:
			plinko.UpdateInput(event)
			zoo.UpdateInput(event)	
			Tutorial.i.TickInput(event)
			
		
func swap_view() -> void:
	SFXPlayer.i.play(SFXPlayer.SFX.SCREEN_SWIPE)
	if my_game_view == GameView.TUTORIAL:	
		%SwapButton.text = " To Space "
		zoo.display()
		%CameraShake.play("Transition")	
		await %CameraShake.animation_finished
		plinko.hide()
		return

	if my_game_view == GameView.PLINKO:
		my_game_view = GameView.ZOO
		%SwapButton.text = " To Space "
		zoo.display()
		%CameraShake.play("Transition")	
		await %CameraShake.animation_finished
		plinko.hide()
	elif my_game_view == GameView.ZOO:
		my_game_view = GameView.PLINKO
		plinko.show()
		%CameraShake.play_backwards("Transition")	
		await %CameraShake.animation_finished
		%SwapButton.text = " To Zoo "
		zoo.undisplay()


func shake_camera() -> void:
	%CameraShake.play("Fire")

func cancel_camera() -> void:
	%CameraShake.play("Cancel")

func button_hover() -> void:
	SFXPlayer.i.play(SFXPlayer.SFX.UI_MOVE)

func button_click(button : Button) -> void:
	if button.disabled:	
		SFXPlayer.i.play(SFXPlayer.SFX.UI_WRONG)
		return

	SFXPlayer.i.play(SFXPlayer.SFX.UI_SELECT)

func find_nodes_of_type(parent_node: Node, target_type: StringName) -> Array[Node]:
	var found_nodes: Array[Node] = []

	# Check if the parent_node itself is of the target type
	if parent_node.is_class(target_type):
		found_nodes.append(parent_node)

	# Recursively search through children
	for child in parent_node.get_children():
		found_nodes.append_array(find_nodes_of_type(child, target_type))

	return found_nodes
