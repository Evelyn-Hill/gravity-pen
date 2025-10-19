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