extends StaticBody2D



func _ready() -> void:
	%Area2D.body_entered.connect(on_body)

func on_body(_body : Node2D) -> void:
	if _body is Alien:
		SFXPlayer.i.play(SFXPlayer.SFX.PILLOW_PLACE, position)
		 
func set_color(color : Color) -> void:
	self.modulate = color
