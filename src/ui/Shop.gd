extends Node


func _ready() -> void:
	%OpenButton.pressed.connect(display_shop)
	%ExitButton.pressed.connect(hide_shop)

func display_shop() -> void:
	%ShopPanel.mouse_filter = %ShopPanel.MOUSE_FILTER_STOP
	%Animation.play("Fade")

func hide_shop() -> void:
	%Animation.play("FadeOut")
	await %Animation.animation_finished
	%ShopPanel.mouse_filter = %ShopPanel.MOUSE_FILTER_IGNORE
	
