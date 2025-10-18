class_name PlinkoGoal
extends StaticBody2D

@export var reward : int = 2

var registered_bodies : Array[Node2D]

func _ready() -> void:
	%RewardLabel.text = str("+ ", reward)
	%DetectionArea.body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D) -> void:
	if body is Alien:
		# Stops a double count of the same body.
		if registered_bodies.has(body):
			return

		registered_bodies.append(body)
		print("+ ", reward) 
		await get_tree().create_timer(1.0).timeout
		body.queue_free()	