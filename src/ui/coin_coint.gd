extends Label


func _ready() -> void:
	text = str("Coins: ", Main.game_state.coins)
	SignalBus.coin_count_changed.connect(func(count): text = str("Coins: ", count))
	pass # Replace with function body.
