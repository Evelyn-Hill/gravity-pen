class_name SFXPlayer
extends Node2D

static var i : SFXPlayer

@export var sfx : Array[Array]
@export var sfx_volume : Array[float]

enum SFX {
	SCREEN_SWIPE = 0,
	ALL_MOVE = 1,
	UI_MOVE = 2,
	UI_SELECT = 3,
	UI_START = 4,
	UI_WRONG = 5,
	PILLOW_PLACE = 6,
	FOOD_CRUNCH = 7,
	BEAM_READY = 8,
	COIN = 9,
	ELECTRIC_CLICK = 10,
	GOAL_1 = 11,
	GOAL_2 = 12,
	GOAL_3 = 13,
	GOAL_4 = 14,
	TYPING = 15,
}

var players : Array[AudioStreamPlayer2D] 

func _enter_tree() -> void:
	i = self

func play(sound : SFX, position : Vector2 = Vector2.ZERO) -> void:
	const PITCH_FLOOR := 0.97
	const PITCH_CEIL = 1.03

	var asp : AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	asp.stream = sfx[sound].pick_random() as AudioStream
	asp.volume_linear = sfx_volume[sound]
	players.append(asp)
	asp.finished.connect(destroy_player.bind(players.size() - 1))
	asp.pitch_scale = randf_range(PITCH_FLOOR, PITCH_CEIL)
	asp.bus = "SFX"
	asp.position = position
	add_child(asp)
	asp.play()

func destroy_player(idx : int) -> void:
	players[idx].queue_free()
