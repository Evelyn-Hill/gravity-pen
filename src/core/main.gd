class_name Main
extends Node2D

enum GameView {
	MENU,
	PLINKO,
	ZOO,
	PAUSE,		
}

var my_game_view : GameView = GameView.PLINKO

@export var plinko : PlinkoBoard
@export var zoo : Node2D

func _ready() -> void:
	print("Hello, Gravity Pen")
	SignalBus.swap_view.connect(swap_view)

func _process(delta: float) -> void:
	match my_game_view:
		GameView.PLINKO:
			pass
		GameView.ZOO:
			pass

func _input(event: InputEvent) -> void:
	match my_game_view:
		GameView.PLINKO:
			pass
		GameView.ZOO:
			pass

func _draw() -> void:
	match my_game_view:
		GameView.PLINKO:
			pass
		GameView.ZOO:
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
