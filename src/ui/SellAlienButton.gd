extends HBoxContainer

@onready var count : Label = get_node("Count")
@onready var button : Button = get_node("Button")

@export var alien_type : Alien.AlienType

func _ready() -> void:
	count.text = str(Zoo.i.count_alien_by_type(alien_type))
	button.pressed.connect(func(): 
		SignalBus.emit_sell_alien(alien_type)
		count.text = str(Zoo.i.count_alien_by_type(alien_type))
	)

func update_count() -> void:
	count.text = str(Zoo.i.count_alien_by_type(alien_type))


