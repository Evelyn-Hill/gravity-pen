class_name Zoo
extends Node2D

var paths : Array[Path2D]

var enclosures : Array[Enclosure]

var patrons : Array[Patron]

const PATRON_SCENE : PackedScene = preload("res://scenes/gameplay/zoo/Patron.tscn")

func _ready() -> void:
	for path in %Paths.get_children():
		paths.append(path)
	
	for enclosure in %Enclosures.get_children():
		enclosures.append(enclosure)

	var patron : Patron = PATRON_SCENE.instantiate()
	patrons.append(patron)
	paths.pick_random().add_child(patron)

func UpdateInput(event : InputEvent) -> void:
	for enclosure in enclosures:
		enclosure.UpdateInput(event)

func Tick(delta : float) -> void:
	pass

func BackgroundTick(delta : float) -> void:
	for patron : Patron in patrons:
		patron.Tick(delta)
	 



