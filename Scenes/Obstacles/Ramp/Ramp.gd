@tool
class_name Ramp
extends Node2D

@export var acceleration_factor = 4
@export var width = 128.0 : set = _set_width

@onready var centre_node = $MiddleTop

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Visuals/Line2D.points = $Visuals/Line2D.points.duplicate()
	$Visuals/Line2D.points[0] = Vector2(-width/2.0, 0)
	$Visuals/Line2D.points[1] = Vector2(width/2.0, 0)
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	var rect :RectangleShape2D = $CollisionShape2D.shape
	rect.size.x = width

func _set_width(newwidth):
	width = newwidth
	$Visuals/Line2D.points[0] = Vector2(-width/2.0, 0)
	$Visuals/Line2D.points[1] = Vector2(width/2.0, 0)

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
