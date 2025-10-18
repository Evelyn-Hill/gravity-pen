class_name PlinkoBoard
extends Node2D

const PLINKO_PIECE := preload("res://scenes/gameplay/plinko/plinko_peg.tscn")
const PLINKO_PIECE_SIZE : Vector2 = Vector2(64, 64)
const ALIEN_SCENE := preload("res://scenes/gameplay/aliens/alien.tscn")

var grid_positions : Array[Vector2]


const peg_colors : Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.BLUE
]

@onready var pen_tool : PenTool = %PenTool
@onready var bacground : MouseParralax = %Background

var aliens : Array[Alien] 

func _ready() -> void:
	generate_board()
	var alien : Alien = ALIEN_SCENE.instantiate()
	aliens.append(alien)
	add_child(alien)


func generate_board() -> void:
	var screen_size : Vector2 = get_viewport_rect().size

	# Split bottom half of screen into grid
	var row_count : int = screen_size.x / PLINKO_PIECE_SIZE.x
	var column_count : int = (screen_size.y / 2) / PLINKO_PIECE_SIZE.y

	print(row_count)
	print(column_count)
	for y in range(column_count - 1):
		for x in range(row_count - 1):
			var x_pos : float = ((position.x - (screen_size.x / 2)) + PLINKO_PIECE_SIZE.x) + (x * PLINKO_PIECE_SIZE.x)
			var y_pos : float = ((position.y + (screen_size.y / 2) - PLINKO_PIECE_SIZE.y )) - (y * PLINKO_PIECE_SIZE.y)

			grid_positions.append(Vector2(x_pos, y_pos))

	for i in range(grid_positions.size()):
		if i % 2 == 0:
			var piece = PLINKO_PIECE.instantiate()
			piece.position = grid_positions[i]
			piece.modulate = peg_colors[i % peg_colors.size()]
			add_child(piece)	

	#queue_redraw()
	
func UpdateInput(event : InputEvent) -> void:
	pen_tool.UpdateInput(event)
	bacground.UpdateInput(event)

func Tick(delta : float) -> void:
	pen_tool.Tick(delta)
	bacground.Tick(delta)
	for alien : Alien in aliens:
		alien.Tick(delta)
