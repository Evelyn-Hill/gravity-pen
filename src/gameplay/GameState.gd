class_name GameState
extends Resource


@export var coins : int = 50
@export var aliens : Dictionary[Alien.AlienType, int]
@export var enclosures : Dictionary[int, Enclosure.EnclosureType]

func add_coins(amount : int) -> void:
	coins += amount
	SignalBus.emit_coin_count_changed(coins)

func add_enclosure(type : Enclosure.EnclosureType) -> int:
	enclosures[enclosures.size()] = type
	return enclosures.size()