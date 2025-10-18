class_name MouseParralax
extends Node2D

@onready var SCREEN_SIZE : Vector2 = get_viewport_rect().size
var mouse_position : Vector2

@export var parralax_amount_pixels : Array[float] = [ 0.0, 35, 75 ]
@export var parralax_speed : Array[float] = [ 0.0, 0.5, 1 ]
var parralax_layers : Array[Sprite2D]

var mouse_normalized_device_coords : Vector2 

func _ready() -> void:
	for child in get_children():
		parralax_layers.append(child)

func UpdateInput(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.position - (SCREEN_SIZE * 0.5)
		mouse_normalized_device_coords = Vector2(mouse_position.x / SCREEN_SIZE.x, mouse_position.y / SCREEN_SIZE.y)
		mouse_normalized_device_coords = Vector2(
			clampf(mouse_normalized_device_coords.x, -1, 1), 
			clampf(mouse_normalized_device_coords.y, -1, 1))

func Tick(delta : float) -> void:
	var count : int = 0
	for layer in parralax_layers:
		var new_position : Vector2 = Vector2(
			(parralax_amount_pixels[count] * mouse_normalized_device_coords.x),	
			(parralax_amount_pixels[count] * mouse_normalized_device_coords.y)	
		)
		layer.position = layer.position.lerp(new_position, parralax_speed[count] * delta)
		count += 1




		
