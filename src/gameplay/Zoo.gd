class_name Zoo
extends Node2D

static var i : Zoo

signal alien_sold()
signal time_to_food(time: float)

var paths : Array[Path2D]
var patrons : Array[Patron]

var homeless_aliens : Array[Alien.AlienType]
var enclosure_aliens : Dictionary[Enclosure, Array]

var food : int = 15

var unfed_aliens : int

const FOOD_COST : int = 1
const SCORE_UPDATE_INTERVAL : float = 5.0
const PATRON_SPAWN_INTERVAL : float = 1
const PATRON_SCENE : PackedScene = preload("res://scenes/gameplay/zoo/Patron.tscn")
const ALIEN_EAT_INTERVAL : float = 30

var score_update_timer : float = SCORE_UPDATE_INTERVAL
var patron_spawn_time : float = PATRON_SPAWN_INTERVAL
var alien_eat_time : float = ALIEN_EAT_INTERVAL

const ZOO_SCORE_PATRON_THRESHOLD : float = 1500

var current_score : int = 50

func _enter_tree() -> void:
	i = self

func _ready() -> void:
	for path in %Paths.get_children():
		paths.append(path)
	
	for enclosure in %Enclosures.get_children():
		enclosure_aliens.get_or_add(enclosure, [])

	spawn_patron()

	SignalBus.alien_collected.connect(on_alien_collected)
	SignalBus.enclosure_purchased.connect(on_enclosure_purchased)
	SignalBus.sell_alien.connect(sell_alien)


func UpdateInput(event : InputEvent) -> void:
	for enclosure in enclosure_aliens:
		enclosure.UpdateInput(event)
	
	if event.is_action_pressed("check_score"):
		print(calculate_zoo_score())

func Tick(delta : float) -> void:
	for enclosure in enclosure_aliens:
		enclosure.Tick(delta)	
	
func BackgroundTick(delta : float) -> void:
	if food <= 0:
		Main.my_game_view = Main.GameView.FAIL
		return

	for patron : Patron in patrons:
		patron.Tick(delta)

	for enclosure in enclosure_aliens:
		enclosure.BackgroundTick(delta)	
		
	score_timer(delta)
	patron_spawn_timer(delta)
	alien_eat_timer(delta)


func calculate_zoo_score() -> int:
	var enclosure_scores : Array[int]
	for enclosure in enclosure_aliens:
		if enclosure.selected_enclosure == enclosure.EnclosureType.NONE:
			continue

		var enclosure_score: int = 50

		enclosure_score += enclosure.ENCLOSURE_SCORE[enclosure.selected_enclosure]

		var cleanliness_score = floori((enclosure.MAX_CLEANLINESS - enclosure.cleanliness) / 2)
		enclosure_score -= clampi(cleanliness_score, 1, enclosure_score)

		for alien in enclosure_aliens[enclosure]:
			enclosure_score += Alien.ALIEN_SCORES[alien]	
		
		enclosure_scores.append(enclosure_score)

		
	var result : int = 0

	for score in enclosure_scores:
		result += score

	var alien_count = count_aliens()

	const FOOD_TIER_ONE := 1.5
	const FOOD_TIER_TWO := 2.5
	if alien_count > 0:
		if food < alien_count:
			return 0
		elif alien_count > food and alien_count < food * FOOD_TIER_ONE:
			result += 5
		elif food > alien_count * FOOD_TIER_ONE and food < alien_count * FOOD_TIER_TWO:
			result += 10
		elif food > alien_count * FOOD_TIER_TWO:
			result += 20

	if result == 0:
		result = 50

	print("Zoo Score: ", result)
	return result

func score_timer(delta : float) -> void:
	score_update_timer -= delta

	if score_update_timer <= 0:
		current_score = calculate_zoo_score()	
		score_update_timer = SCORE_UPDATE_INTERVAL

func patron_spawn_timer(delta : float) -> void:
	patron_spawn_time -= delta
	
	if patron_spawn_time <= 0:
		spawn_patron()
		patron_spawn_time = PATRON_SPAWN_INTERVAL * (ZOO_SCORE_PATRON_THRESHOLD / current_score)

func alien_eat_timer(delta: float) -> void:
	alien_eat_time -= delta
	time_to_food.emit(alien_eat_time)		
	if alien_eat_time <= 0:
		feed_aliens()

func feed_aliens() -> void:
	alien_eat_time = ALIEN_EAT_INTERVAL
	food -= count_aliens()		
	SFXPlayer.i.play(SFXPlayer.SFX.FOOD_CRUNCH)
	SignalBus.emit_feeding_occured(food)

func spawn_patron() -> void:
	var patron : Patron = PATRON_SCENE.instantiate()
	patrons.append(patron)
	Main.game_state.add_coins(2)
	paths.pick_random().add_child(patron)

func have_space() -> Enclosure:
	for enclosure in enclosure_aliens:
		if enclosure.selected_enclosure == Enclosure.EnclosureType.NONE:
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

	SignalBus.emit_homeless_aliens_updated(homeless_aliens)

func on_enclosure_purchased() -> void:
	distribute_aliens()

func remove_patron(patron : Patron) -> void:
	patrons.remove_at(patrons.find(patron))
	if current_score != 0:	
		Main.game_state.add_coins(clamp(current_score / 12, 1, 15))

func count_aliens() -> int:
	var total : int = 0
	for enclosure in enclosure_aliens:
		total += enclosure_aliens[enclosure].size()
	
	total += homeless_aliens.size()

	return total

func count_alien_by_type(type: Alien.AlienType) -> int:
	var total : int = 0
	for enclosure in enclosure_aliens:
		for alien in enclosure_aliens[enclosure]:
			if alien == type:
				total += 1
		
	for alien in homeless_aliens:
		if alien == type:
			total += 1

	return total

func sell_alien(type: Alien.AlienType) -> int:
	# Awful nesting...
	for enclosure in enclosure_aliens:
		for alien in enclosure_aliens[enclosure]:
			if alien == type:
				enclosure_aliens[enclosure].remove_at(enclosure_aliens[enclosure].find(alien))	
				alien_sold.emit()
				Main.game_state.add_coins(1)
				return count_alien_by_type(type)
	
	return count_alien_by_type(type)

func calculate_food_cost(amount : int) -> int:
	return FOOD_COST * amount

func purchase_food(amount : int) -> bool:
	if Main.game_state.coins >= calculate_food_cost(amount):
		food += amount
		Main.game_state.add_coins(-calculate_food_cost(amount))
		SignalBus.emit_food_purchased(food)
		return true
	
	return false

func calculate_food_needed() -> int:
	return count_aliens()	

func get_enclosure_alien_count(enclosure : Enclosure) -> Array[int]:
	if enclosure.selected_enclosure == Enclosure.EnclosureType.NONE:
		return [0, 0, 0]

	var boring : int = 0
	var awesome: int = 0
	var epic : int = 0

	for alien in enclosure_aliens[enclosure]:
		if alien == Alien.AlienType.BORING:
			boring += 1
		elif alien == Alien.AlienType.AWESOME:
			awesome += 1
		elif alien == Alien.AlienType.EPIC:
			epic += 1
	
	return [boring, awesome, epic]


func display() -> void:
	self.visible = true
	%Shop.visible = true

func undisplay() -> void:
	self.visible = false
	%Shop.visible = false
	
		