extends Label

const TEMPLATE_STRING : String = "Unhoused Aliens: "

func _ready() -> void:
	SignalBus.homeless_aliens_updated.connect(func(aliens): 
		text = str(TEMPLATE_STRING, aliens.size())
	)


