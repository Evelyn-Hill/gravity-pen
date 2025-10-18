class_name Main
extends Node2D

enum GameView {
	MENU,
	PLINKO,
	ZOO,
	PAUSE,		
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
			pass
		GameView.ZOO:
			zoo.Tick(delta)
			pass

func _input(event: InputEvent) -> void:
	match my_game_view:
		GameView.PLINKO:
			plinko.UpdateInput(event)
			pass
		GameView.ZOO:
			zoo.UpdateInput(event)
			pass
	
		
func swap_view() -> void:
	if my_game_view == GameView.PLINKO:
		my_game_view = GameView.ZOO
		plinko.hide()
		zoo.show()
	elif my_game_view == GameView.ZOO:
		my_game_view = GameView.PLINKO
		zoo.hide()
		plinko.show()
