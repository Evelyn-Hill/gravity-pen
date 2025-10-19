extends Label


func _ready() -> void:
	text = str(Main.game_state.coins)
	SignalBus.coin_count_changed.connect(func(count): text = str(count))
