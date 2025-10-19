class_name TutorialScene
extends Resource


@export var sprites : Array[Texture2D]
@export var flip_sprite : Array[bool]

@export var texts : Array[String]

@export var node_visible : Dictionary[int, NodePath]

@export var wait_moments : Dictionary[int, StringName]

@export var commands : Dictionary[int, StringName]
