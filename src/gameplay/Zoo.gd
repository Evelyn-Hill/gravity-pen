class_name Zoo
extends Node2D

static var i : Zoo

var paths : Array[Path2D]
var patrons : Array[Patron]

var homeless_aliens : Array[Alien.AlienType]

var enclosure_aliens : Dictionary[Enclosure, Array]

const PATRON_SCENE : PackedScene = preload("res://scenes/gameplay/zoo/Patron.tscn")

func _enter_tree() -> void:
	i = self

func _ready() -> void:
	for path in %Paths.get_children():
		paths.append(path)
	
	for enclosure in %Enclosures.get_children():
		enclosure_aliens.get_or_add(enclosure, [])

	var patron : Patron = PATRON_SCENE.instantiate()
	patrons.append(patron)
	paths.pick_random().add_child(patron)

	SignalBus.alien_collected.connect(on_alien_collected)
	SignalBus.enclosure_purchased.connect(on_enclosure_purchased)


func UpdateInput(event : InputEvent) -> void:
	for enclosure in enclosure_aliens:
		enclosure.UpdateInput(event)

func Tick(delta : float) -> void:
	pass

func BackgroundTick(delta : float) -> void:
	for patron : Patron in patrons:
		patron.Tick(delta)

func calculate_zoo_score() -> void:
	pass

func have_space() -> Enclosure:
	for enclosure in enclosure_aliens:
		if enclosure.selected_enclosure == Enclosure.EnclosureType.NONE:
			print("NONE")
			continue
			
		if enclosure_aliens[enclosure].size() < enclosure.MAX_ALIENS[enclosure.selected_enclosure]:
			return enclosure
	
	return null

func on_alien_collected(type: Alien.AlienType) -> void:
	homeless_aliens.append(type)
	distribute_aliens()	
	 
func distribute_aliens() -> void:
	for alien in homeless_aliens:	
		var enclosure = have_space()
		if enclosure != null:
			homeless_aliens.remove_at(homeless_aliens.find(alien))
			enclosure_aliens[enclosure].append(alien)

	print(enclosure_aliens)
	print(homeless_aliens)

func on_enclosure_purchased() -> void:
	distribute_aliens()



