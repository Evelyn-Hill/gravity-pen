class_name PlinkoGoal
extends StaticBody2D


var registered_bodies : Array[Node2D]

enum Reward {
	TEN_GOLD,
	TEN_FOOD,
	TWENTY_GOLD,
	TWENTY_FOOD,
}

var methods : Array[Callable] = [
	add_ten_gold,
	add_ten_food,	
	add_twenty_gold,
	add_twenty_food
]

@export var my_reward : Reward

@export var reward_nodes : Array[Control] = []


func _ready() -> void:
	%DetectionArea.body_entered.connect(_on_body_entered)
	reward_nodes[my_reward].show()

func _on_body_entered(body : Node2D) -> void:
	if body is Alien:
		# Stops a double count of the same body.
		if registered_bodies.has(body):
			return

		registered_bodies.append(body)

		methods[my_reward].call()

func add_ten_gold() -> void:
	Main.game_state.add_coins(10)
	SFXPlayer.i.play(SFXPlayer.SFX.COIN, global_position)

func add_ten_food() -> void:
	Zoo.i.purchase_food(10)
	SFXPlayer.i.play(SFXPlayer.SFX.COIN, global_position)

func add_twenty_gold() -> void:
	Main.game_state.add_coins(20)
	SFXPlayer.i.play(SFXPlayer.SFX.COIN, global_position)

func add_twenty_food() -> void:
	Zoo.i.purchase_food(20)
	SFXPlayer.i.play(SFXPlayer.SFX.COIN, global_position)