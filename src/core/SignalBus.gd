extends Node

signal swap_view()
func emit_swap_view() -> void:
	swap_view.emit()

signal coin_count_changed(new_count : int)
func emit_coin_count_changed(new_count: int) -> void:
	coin_count_changed.emit(new_count)

signal alien_collected(type : Alien.AlienType)
func emit_alien_collected(type: Alien.AlienType) -> void:
	alien_collected.emit(type)

signal enclosure_purchased()
func emit_enclosure_purchased() -> void:
	enclosure_purchased.emit()

signal homeless_aliens_updated(aliens : Array[Alien.AlienType])
func emit_homeless_aliens_updated(aliens : Array[Alien.AlienType]) -> void:
	homeless_aliens_updated.emit(aliens)

signal shop_requested()
func emit_shop_requested() -> void:
	shop_requested.emit()

signal sell_alien(type : Alien.AlienType)
func emit_sell_alien(type : Alien.AlienType) -> void:
	sell_alien.emit(type)

signal feeding_occured(food: int)
func emit_feeding_occured(food: int) -> void:
	feeding_occured.emit(food)

signal food_purchased(food: int) 
func emit_food_purchased(food: int) -> void:
	food_purchased.emit(food) 

signal aliens_ditributed()
func emit_aliens_ditributed() -> void:
	aliens_ditributed.emit()

signal tut_alien_collected()
func emit_tut_alien_collected() -> void:
	tut_alien_collected.emit()

signal swap_screen()
func emit_swap_screen() -> void:
	swap_screen.emit()

signal dirty_first_enclosure()
func emit_dirty_first_enclosure() -> void:
	dirty_first_enclosure.emit()	

