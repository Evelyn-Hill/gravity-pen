class_name Main
extends Node2D

enum GameView {
	MENU,
	PLINKO,
	ZOO,
	PAUSE,		
	TUTORIAL,
}

static var my_game_view : GameView = GameView.PLINKO

static var game_state : GameState = GameState.new()

@export var plinko : PlinkoBoard
@export var zoo : Zoo

func _ready() -> void:
	print("Hello, Gravity Pen")
	SignalBus.swap_view.connect(swap_view)

func _process(delta: float) -> void:

	match my_game_view:
		GameView.PLINKO:
			plinko.Tick(delta)
			zoo.BackgroundTick(delta)
			plinko.BackgroundTick(delta)
		GameView.ZOO:
			zoo.Tick(delta)
			zoo.BackgroundTick(delta)
			plinko.BackgroundTick(delta)

func _input(event: InputEvent) -> void:
	match my_game_view:
		GameView.PLINKO:
			plinko.UpdateInput(event)
		GameView.ZOO:
			zoo.UpdateInput(event)
	
		
func swap_view() -> void:
	if my_game_view == GameView.PLINKO:
		my_game_view = GameView.ZOO
		%SwapButton.text = " To Space "
		plinko.hide()
		zoo.display()
	elif my_game_view == GameView.ZOO:
		my_game_view = GameView.PLINKO
		%SwapButton.text = " To Zoo "
		zoo.undisplay()
		plinko.show()
