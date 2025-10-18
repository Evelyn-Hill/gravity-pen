class_name Zoo
extends Node2D

var paths : Array[Path2D]

var enclosures : Array[Enclosure]

const PATRON_SCENE : PackedScene = preload("res://scenes/gameplay/zoo/Patron.tscn")

func _ready() -> void:
	for path in %Paths.get_children():
		paths.append(path)
	
	for enclosure in %Enclosures.get_children():
		enclosures.append(enclosure)

	var patron : Patron = PATRON_SCENE.instantiate()
	paths.pick_random().add_child(patron)	

