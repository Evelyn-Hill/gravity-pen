extends Node

signal swap_view()
func emit_swap_view() -> void:
	swap_view.emit()

signal coin_count_changed(new_count : int)
func emit_coin_count_changed(new_count: int) -> void:
	coin_count_changed.emit(new_count)
