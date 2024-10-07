@tool
class_name Wall
extends StaticBody2D

@export var acceleration_factor = 0
@export var height = 128.0 : set = _set_height

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Visuals/Line2D.points = $Visuals/Line2D.points.duplicate()
	$Visuals/Line2D.points[0] = Vector2(0, height/2.0)
	$Visuals/Line2D.points[1] = Vector2(0, -height/2.0)
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	var rect :RectangleShape2D = $CollisionShape2D.shape
	rect.size.y = height

func _set_height(newheight):
	height = newheight
	$Visuals/Line2D.points[0] = Vector2(0, height/2.0)
	$Visuals/Line2D.points[1] = Vector2(0, -height/2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
