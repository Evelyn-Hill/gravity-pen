class_name Enclosure
extends Node2D

enum EnclosureType {
	NONE = 0,
	DESERT = 1,
	JUNGLE = 2,
	MOUNTAIN = 3,
}

const ENCLOSURE_SCORE : Array[int] = [ 0, 1, 3, 5 ]

@export var enclosure_nodes : Array[Node2D] 

var selected_enclosure : EnclosureType = EnclosureType.NONE

func select_enclosure(type: EnclosureType) -> void:	
	selected_enclosure = type	
	enclosure_nodes[selected_enclosure].show()

func get_enclosure_score() -> int:
	return ENCLOSURE_SCORE[selected_enclosure]
