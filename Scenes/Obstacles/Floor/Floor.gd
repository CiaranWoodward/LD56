class_name Floor
extends StaticBody2D

@export var acceleration_factor = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func floor_y() -> float:
	return $Top.global_position.y

func is_in_landing_plane(point: Vector2) -> bool:
	var up_vector = Vector2.from_angle($Top.global_rotation)
	var line_position = $Top.global_position
	var is_point_above_line : bool = (point - line_position).dot(up_vector) > 0
	return is_point_above_line
