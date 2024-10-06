class_name Ramp
extends Node2D

@export var acceleration_factor = 4

@onready var centre_node = $Centre

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_ramp_centre() -> Vector2:
	return centre_node.global_position

func is_in_landing_plane(point: Vector2) -> bool:
	var up_vector = Vector2.from_angle($MiddleTop.global_rotation)
	var line_position = $MiddleTop.global_position
	var is_point_above_line : bool = (point - line_position).dot(up_vector) > 0
	return is_point_above_line
