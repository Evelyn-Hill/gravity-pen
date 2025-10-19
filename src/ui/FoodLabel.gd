extends Label

func _ready() -> void:
	text = str(Zoo.i.food)
	SignalBus.feeding_occured.connect(func(food): text = str(food))
	SignalBus.food_purchased.connect(func(food): text = str(food))
