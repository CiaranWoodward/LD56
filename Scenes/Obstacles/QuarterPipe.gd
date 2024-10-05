class_name QuarterPipe
extends StaticBody2D

@onready var centre_node = $Centre

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_pipe_centre()-> Vector2:
	return centre_node.global_position

# Get the exit vector, if the direction is an exit vector. Otherwise return Vector2.ZERO
func get_exit_vector(quarter_pipe_dir: int, global_dir : Vector2) -> Vector2:
	if abs($Exit1.global_rotation - global_dir.angle()) < 0.15 && quarter_pipe_dir == 1:
		return Vector2.from_angle($Exit1.global_rotation)
	if abs($Exit2.global_rotation - global_dir.angle()) < 0.15 && quarter_pipe_dir == -1:
		return Vector2.from_angle($Exit2.global_rotation)
	return Vector2.ZERO

# Use the global dir vector to determine whether the vector is going clockwise or anticlockwise
# around the circle
func get_direction(global_pos: Vector2, global_dir: Vector2) -> int:
	var p1 = global_pos - get_pipe_centre()
	var p2 = p1 + global_dir
	var cross = p2.cross(p1)
	if cross > 0:
		print("Clock")
		return -1
	else:
		print("Anticlock")
		return 1   # Anticlockwise

func get_radius() -> float:
	return get_pipe_centre().distance_to($Exit2.global_position)
