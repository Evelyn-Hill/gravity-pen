extends Area2D

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body : Node2D) -> void:
	if body is Alien:
		print(body.my_alien_type)
		Main.game_state.add_alien(body.my_alien_type)
		body.destroy()
