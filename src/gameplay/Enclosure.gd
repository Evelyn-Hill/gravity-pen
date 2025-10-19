class_name Enclosure
extends Node2D

enum EnclosureType {
	NONE = 0,
	DESERT = 1,
	JUNGLE = 2,
	MOUNTAIN = 3,
}

const ENCLOSURE_SCORE : Array[int] = [ 0, 1, 3, 5 ]

const MAX_ALIENS : Array[int] = [ 0, 15, 35, 50 ]

const MAX_CLEANLINESS : int = 100
const MIN_CLEANLINESS : int = 0
const DIRTY_THRESHOLD : int = 45
const CLEANLINESS_SPEED : float = 0.2

var cleanliness : float = MAX_CLEANLINESS

@export var enclosure_nodes : Array[Node2D] 

var selected_enclosure : EnclosureType = EnclosureType.NONE

var mouse_inside : bool = false

var base_enclosure_cost : int = 50

@export var purchase_buttons : Array[TextureButton]

func _ready() -> void:
	%ClickArea.mouse_entered.connect(func(): mouse_inside = true)
	%ClickArea.mouse_exited.connect(func(): mouse_inside = false)
	%CleanButton.pressed.connect(clean_enclosure)

	for button in purchase_buttons:
		connect_button_signals(button)

func connect_button_signals(button : TextureButton) -> void:
	button.modulate = Color.GRAY
	button.mouse_entered.connect(func(): button.modulate = Color.WHITE)
	button.mouse_exited.connect(func(): button.modulate = Color.GRAY)	
	button.pressed.connect(handle_purchase_request.bind(button))
	var enclosure_index = purchase_buttons.find(button) + 1
	button.get_parent().get_node("Label").text = str(ENCLOSURE_SCORE[enclosure_index] * base_enclosure_cost, " coins")				
	
func handle_purchase_request(button : TextureButton) -> void:
	for b in purchase_buttons:
		if b == button:
			var enclosure_index = purchase_buttons.find(b) + 1
			if ENCLOSURE_SCORE[enclosure_index] * base_enclosure_cost <= Main.game_state.coins:
				select_enclosure(enclosure_index)
				Main.game_state.add_enclosure(selected_enclosure)
				Main.game_state.add_coins(-(ENCLOSURE_SCORE[enclosure_index] * base_enclosure_cost))
				SignalBus.emit_enclosure_purchased()
				%BuyMenu.hide()

func select_enclosure(type: EnclosureType) -> void:	
	selected_enclosure = type	
	enclosure_nodes[selected_enclosure].show()

func get_enclosure_score() -> int:
	return ENCLOSURE_SCORE[selected_enclosure]

func BackgroundTick(delta : float) -> void:
	if selected_enclosure != EnclosureType.NONE:
		cleanliness -= delta * CLEANLINESS_SPEED
		%CleanlinessSlider.value = cleanliness

func clean_enclosure() -> void:
	cleanliness = MAX_CLEANLINESS


func UpdateInput(event: InputEvent) -> void:
	if event.is_action_pressed("click") and mouse_inside:
		%BuyMenu.visible = !%BuyMenu.visible
		for n in get_parent().get_children():
			if n != self:
				n.get_node("%BuyMenu").hide()
