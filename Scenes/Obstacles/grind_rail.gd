class_name GrindRail
extends Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var prev_point = Vector2.INF
	for point in points:
		if prev_point == Vector2.INF:
			prev_point = point
			continue
		var new_cshape = CollisionShape2D.new()
		var segshape = SegmentShape2D.new()
		new_cshape.shape = segshape
		$GrindRailBody.add_child(new_cshape)
		segshape.a = prev_point
		segshape.b = point
		prev_point = point

func _get_distance_to_line_segment(p: Vector2, a: Vector2, b: Vector2) -> Array:
	var ab = b - a
	var ap = p - a
	var ab_squared = ab.length_squared()
	var dot_product = ap.dot(ab)
	var t = dot_product / ab_squared

	# Check nearest point is within segment
	if t < 0 or t > 1:
		return [INF, Vector2.INF]

	var closest_point = a + ab * t
	var distance = p.distance_to(closest_point)
	return [distance, closest_point]

func get_current_direction_and_position(global_pos: Vector2, direction: Vector2, threshold: float = 50.0):
	var best_distance = threshold+1
	var best_direction = Vector2.ZERO
	var best_position = global_pos
	for i in range(points.size() - 1):
		var a = points[i]
		var b = points[i + 1]
		var result = _get_distance_to_line_segment(global_pos, a + global_position, b + global_position)
		var distance_to_ls = result[0]
		var closest_point = result[1]
		if distance_to_ls < threshold && distance_to_ls < best_distance:
			var rval = (b - a).normalized()
			if rval.dot(direction) < 0:
				rval = -rval
			best_distance = distance_to_ls
			best_direction = rval
			best_position = closest_point
	return [best_direction, best_position]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
