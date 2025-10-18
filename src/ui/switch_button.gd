extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(func(): SignalBus.emit_swap_view())


