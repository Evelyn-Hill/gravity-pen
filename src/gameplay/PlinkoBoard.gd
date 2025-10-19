class_name PlinkoBoard
extends Node2D

static var i 

const PLINKO_PIECE := preload("res://scenes/gameplay/plinko/plinko_peg.tscn")
const PLINKO_PIECE_SIZE : Vector2 = Vector2(64, 64)
const ALIEN_SCENE := preload("res://scenes/gameplay/aliens/alien.tscn")

var grid_positions : Array[Vector2]

const peg_colors : Array[Color] = [
	Color.RED,
	Color.GREEN,
	Color.BLUE
]

const MIN_SPAWN_TIME : float = 1.5
const MAX_SPAWN_TIME : float = 3.0


@onready var pen_tool : PenTool = %PenTool
@onready var bacground : MouseParralax = %Background

@onready var alien_spawn_1 : Node2D = %AlienSpawn1
@onready var alien_spawn_2 : Node2D = %AlienSpawn2

var aliens : Array[Alien] 

func _enter_tree() -> void:
	i = self

func _ready() -> void:
	generate_board()
	alien_spawn_timer()

func alien_spawn_timer() -> void:
	spawn_aliens()
	await get_tree().create_timer(randf_range(MIN_SPAWN_TIME, MAX_SPAWN_TIME)).timeout
	alien_spawn_timer()

func spawn_aliens() -> void:
	const VERTICAL_HEIGHT_RANDOM_MAX : float = 45
	var side : float = randf_range(0, 10)	
	var alien : Alien = null
	alien = ALIEN_SCENE.instantiate()

	alien.set_alien_type(decide_alien_type())	

	var y_random : float = randf_range(-VERTICAL_HEIGHT_RANDOM_MAX, VERTICAL_HEIGHT_RANDOM_MAX)

	var spawn_pos : Vector2
	if side < 5:
		spawn_pos = Vector2(alien_spawn_1.position.x, alien_spawn_1.position.y + y_random)
		alien.direction = Vector2(1, 0)
	else:
		spawn_pos = Vector2(alien_spawn_2.position.x, alien_spawn_2.position.y + y_random)
		alien.direction = Vector2(-1, 0)

	print(spawn_pos)	
	alien.position = spawn_pos
	aliens.append(alien)	
	%Aliens.add_child(aliens.back())

func decide_alien_type() -> Alien.AlienType:
	const AWESOME_SPAWN_RATE : int = 40
	const EPIC_SPAWN_RATE : int = 20

	var random_number : int = randi_range(0, 100)

	if random_number < EPIC_SPAWN_RATE:
		return Alien.AlienType.EPIC
	
	if random_number < AWESOME_SPAWN_RATE:
		return Alien.AlienType.AWESOME
	
	return Alien.AlienType.BORING


func generate_board() -> void:
	var screen_size : Vector2 = get_viewport_rect().size

	# Split bottom half of screen into grid
	var row_count : int = screen_size.x / PLINKO_PIECE_SIZE.x
	var column_count : int = (screen_size.y / 2) / PLINKO_PIECE_SIZE.y

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

func remove_alien(alien : Alien) -> void:
	if !aliens.has(alien):
		return

	aliens.remove_at(aliens.find(alien))

func UpdateInput(event : InputEvent) -> void:
	pen_tool.UpdateInput(event)
	bacground.UpdateInput(event)

func BackgroundTick(delta : float) -> void:
	for alien : Alien in aliens:
		alien.Tick(delta)

func Tick(delta : float) -> void:
	pen_tool.Tick(delta)
	bacground.Tick(delta)
