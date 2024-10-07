@tool

class_name ThirdPipe
extends StaticBody2D

@export var NUM_POINTS = 8
@export var radius = 190 : set = _set_radius
@export var ramp_angle_degrees = 60 : set = _set_ramp_angle

@onready var centre_node = $Centre

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gen_arc_points($Centre.position, PI/2, PI/2 + deg_to_rad(ramp_angle_degrees))

func _clear_collision_shapes():
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()

func gen_arc_points(center: Vector2, start_angle: float, end_angle: float):
	var visual_radius = radius + $Visuals/Line2D.width/2
	var points = PackedVector2Array() 
	var angle_step = (end_angle - start_angle) / (NUM_POINTS - 1)

	var prev_collis : Vector2 = Vector2.ZERO
	for i in range(NUM_POINTS):
		var angle = start_angle + i * angle_step
		var x = center.x + visual_radius * cos(angle)
		var y = center.y + visual_radius * sin(angle)
		var x_collis = center.x + radius * cos(angle)
		var y_collis = center.y + radius * sin(angle)
		points.append(Vector2(x, y))
		var new_collis = Vector2(x_collis, y_collis)
		if !prev_collis.is_zero_approx():
			var new_collis_shape = CollisionShape2D.new()
			var segshape = SegmentShape2D.new()
			segshape.a = prev_collis
			segshape.b = new_collis
			new_collis_shape.shape = segshape
			add_child(new_collis_shape)
		prev_collis = new_collis
	$Visuals/Line2D.points = points
	var new_maxbounds = RectangleShape2D.new()
	var y_height = -prev_collis.y
	new_maxbounds.size = Vector2(radius*1.1, (y_height) * 1.1)
	$MaxBounds/CollisionShape2D.shape = new_maxbounds
	$MaxBounds/CollisionShape2D.position = Vector2(-radius/2 + $Centre.position.x, -y_height/2)
	$Exit1.position = prev_collis
	$Exit1.rotation = -PI + end_angle - PI/2

func _set_radius(new_rad):
	radius = new_rad
	gen_arc_points($Centre.position, PI/2, PI/2 + deg_to_rad(ramp_angle_degrees))

func _set_ramp_angle(new_ang):
	ramp_angle_degrees = new_ang
	if !is_instance_valid($Centre):
		return
	gen_arc_points($Centre.position, PI/2, PI/2 + deg_to_rad(ramp_angle_degrees))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_max_bounds() -> Area2D:
	return $MaxBounds

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
		#print("Clock")
		return -1
	else:
		#print("Anticlock")
		return 1   # Anticlockwise

func get_speed_component_at_entrance(global_pos: Vector2, global_dir: Vector2) -> float:
	var p1 = global_pos - get_pipe_centre()
	var p2 = Vector2(p1.y, p1.x)
	var dot = global_dir.dot(p2)
	return abs(dot / p2.length())

func get_radius() -> float:
	return get_pipe_centre().distance_to($Exit2.global_position)
