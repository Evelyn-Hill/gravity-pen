class_name Enclosure
extends Node2D

enum EnclosureType {
	NONE = 0,
	DESERT = 1,
	JUNGLE = 2,
	MOUNTAIN = 3,
}

const ENCLOSURE_SCORE : Array[int] = [ 0, 10, 17, 25 ]

const MAX_ALIENS : Array[int] = [ 0, 15, 35, 75 ]

const MAX_CLEANLINESS : int = 100
const MIN_CLEANLINESS : int = 0
const DIRTY_THRESHOLD : int = 45
const CLEANLINESS_SPEED : float = 0.2
const CLEANLINESS_SCORE_MODIFIER = 10
const CLEANING_COST : int = 10

var cleanliness : float = MAX_CLEANLINESS

@export var enclosure_nodes : Array[Node2D] 

var selected_enclosure : EnclosureType = EnclosureType.NONE

var mouse_inside : bool = false

var base_enclosure_cost : int = 2

@export var wander_size : float = 175

var wander_rect : Rect2 = Rect2(
	Vector2(self.global_position.x - (wander_size / 2), self.global_position.y - (wander_size / 2)), 
	Vector2(wander_size, wander_size))

const ENCLOSURE_ALIEN_SCENES : Array[PackedScene] = [
	preload("res://scenes/gameplay/zoo/ZooBoring.tscn"),
	preload("res://scenes/gameplay/zoo/ZooAwesome.tscn"),
	preload("res://scenes/gameplay/zoo/ZooEpic.tscn")
]

var MAX_ENCLOSURE_ALIENS : int = 3

var enclosure_alien_visuals : Array[ZooAlien]


@export var purchase_buttons : Array[TextureButton]
@export var purchase_labels : Array[HBoxContainer]
@export var v_separator : Array[VSeparator]



func _ready() -> void:
	%ClickArea.mouse_entered.connect(func(): mouse_inside = true)
	%ClickArea.mouse_exited.connect(func(): mouse_inside = false)
	%CleanButton.pressed.connect(clean_enclosure)
	SignalBus.homeless_aliens_updated.connect(on_homeless_aliens_updated)
	Zoo.i.alien_sold.connect(on_alien_sold)

	for button in purchase_buttons:
		connect_button_signals(button)


func connect_button_signals(button : TextureButton) -> void:
	button.modulate = Color.GRAY
	button.mouse_entered.connect(func(): button.modulate = Color.WHITE)
	button.mouse_exited.connect(func(): button.modulate = Color.GRAY)	
	button.pressed.connect(handle_purchase_request.bind(button))
	var enclosure_index = purchase_buttons.find(button) + 1
	button.get_parent().get_node("HBoxContainer").get_node("Label").text = str(MAX_ALIENS[enclosure_index] * base_enclosure_cost)				
	
func handle_purchase_request(button : TextureButton) -> void:
	for b in purchase_buttons:
		if b == button:
			var enclosure_index = purchase_buttons.find(b) + 1
			if ENCLOSURE_SCORE[enclosure_index] * base_enclosure_cost <= Main.game_state.coins:
				select_enclosure(enclosure_index)
				Main.game_state.add_enclosure(selected_enclosure)
				Main.game_state.add_coins(-(MAX_ALIENS[enclosure_index] * base_enclosure_cost))
				SignalBus.emit_enclosure_purchased()
				%BuyMenu.hide()

func select_enclosure(type: EnclosureType) -> void:	
	selected_enclosure = type	
	%Capacity.max_value = MAX_ALIENS[type]
	%Capacity.modulate = Color.WHITE
	purchase_buttons[selected_enclosure - 1].queue_free()
	purchase_labels[selected_enclosure - 1].queue_free()
	v_separator[selected_enclosure - 1].queue_free()
	fade_in_enclosure(enclosure_nodes[selected_enclosure])	

func get_enclosure_score() -> int:
	return ENCLOSURE_SCORE[selected_enclosure]

func BackgroundTick(delta : float) -> void:
	if selected_enclosure != EnclosureType.NONE:
		cleanliness -= delta * CLEANLINESS_SPEED
		var stinky_opacity : float = 1 - (cleanliness / MAX_CLEANLINESS)
		%STINKY.modulate = Color(1, 1, 1, stinky_opacity)		

func Tick(delta : float) -> void:
	for alien in enclosure_alien_visuals:
		alien.Tick(delta)

func clean_enclosure() -> void:
	if Main.game_state.coins >= CLEANING_COST:
		cleanliness = MAX_CLEANLINESS
		Main.game_state.add_coins(-CLEANING_COST)


func UpdateInput(event: InputEvent) -> void:
	if event.is_action_pressed("click") and mouse_inside:
		set_buy_menu(!%BuyMenu.visible)

		for n in get_parent().get_children():
			if n == self:
				continue
			n.set_buy_menu(false)	
		

func set_buy_menu(state : bool) -> void:
	%BuyMenu.visible = state
	%Capacity.visible = !state
	if selected_enclosure != EnclosureType.NONE and cleanliness < 50:
		%CleanContainer.show()
	else:
		%CleanContainer.hide()



func count_instanced_aliens() -> Array[int]:
	var boring : int = 0			
	var awesome : int = 0			
	var epic : int = 0			

	for a in enclosure_alien_visuals:
		if a.type == Alien.AlienType.BORING:
			boring += 1
		elif a.type == Alien.AlienType.AWESOME:
			awesome += 1
		elif a.type == Alien.AlienType.EPIC:
			epic += 1
	
	return [boring, awesome, epic]


func synchronize_alien_display() -> void:
	var alien_count = Zoo.i.get_enclosure_alien_count(self)
	var instanced_alien_count : Array[int] = count_instanced_aliens()

	#%Capacity.value = alien_count

	for i in range(alien_count.size()):
		if alien_count[i] > 0 and instanced_alien_count[i] == 0:
			print("Add alien: ", i)
			var alien = ENCLOSURE_ALIEN_SCENES[i].instantiate()
			enclosure_alien_visuals.append(alien)
			add_child(alien)						
		elif alien_count[i] < 1 and instanced_alien_count[i] > 0:
			for a in enclosure_alien_visuals:
				if a.type == i:
					print("Remove alien: ", i)
					enclosure_alien_visuals.remove_at(enclosure_alien_visuals.find(a))
					a.queue_free()

func on_homeless_aliens_updated(aliens) -> void:
	if selected_enclosure != EnclosureType.NONE:
		synchronize_alien_display()
	else:
		print("Not set")

func on_alien_sold() -> void:
	if selected_enclosure != EnclosureType.NONE:
		synchronize_alien_display()
	
func fade_in_enclosure(enclosure: Node2D) -> void:
	enclosure.modulate = Color.TRANSPARENT
	enclosure.show()
	const TWEEN_TIME : float = 0.5
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(enclosure, "modulate", Color.WHITE, TWEEN_TIME)

	for a in enclosure_alien_visuals:
		a.modulate = Color.TRANSPARENT
		tween.tween_property(enclosure, "modulate", Color.WHITE, TWEEN_TIME)
		
		
