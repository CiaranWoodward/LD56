class_name Floor
extends StaticBody2D

@export var acceleration_factor = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func floor_y() -> float:
	return $Top.global_position.y
