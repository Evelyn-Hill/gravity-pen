extends Node


@onready var food_slider : HSlider = get_node("FoodSlider")
@onready var purchase_button : Button = get_node("Button")
@onready var cost_label : Label = get_node("%FoodCostLabel")
@onready var food_needed_label : Label = get_node("%FoodNeededLabel")

const FOOD_COST_STRING : Array[String] = ["Cost ", " coins"]
const FOOD_NEEDED_STRING : Array[String] = ["You need ", " food"]

func _ready() -> void:
	cost_label.modulate = Color.GREEN
	food_slider.value_changed.connect(on_value_changed)
	purchase_button.pressed.connect(purchase_food)
	Zoo.i.alien_sold.connect(on_sell_alien)
	on_value_changed(0)

func update_slider_value() -> void:
	var alien_count : int = Zoo.i.count_aliens()	
	food_needed_label.text = str(FOOD_NEEDED_STRING[0], Zoo.i.calculate_food_needed(), FOOD_NEEDED_STRING[1])

	if alien_count == 0:
		food_slider.editable = false
		purchase_button.disabled = true
		return
	else:
		food_slider.editable = true
		purchase_button.disabled = false

	food_slider.max_value = alien_count * 2
	food_slider.tick_count = clamp(food_slider.max_value, 2, 10)			
	food_slider.value = food_slider.tick_count / 2

func on_value_changed(value : float) -> void:
	cost_label.text = str(FOOD_COST_STRING[0], Zoo.i.calculate_food_cost(value), FOOD_COST_STRING[1])

	if Main.game_state.coins >= Zoo.i.calculate_food_cost(value):
		cost_label.modulate = Color.GREEN
	else:
		cost_label.modulate = Color.RED
		
func purchase_food() -> void:
	var success = Zoo.i.purchase_food(food_slider.value)
	if success:
		food_slider.value = 0
		
func on_sell_alien() -> void:
	print("Sold from food panel")
	update_slider_value()

