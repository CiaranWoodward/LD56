extends CharacterBody2D

const JUMP_VELOCITY = -400.0

@export var MAX_SPEED = 1000

@onready var aoe = $AreaOfEffect

var gravity_effect : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2(-1, 0);
var acceleration = 0
var speed = 1
var on_floor = false
var quarter_pipe_direction = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not on_floor:
		gravity_effect += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and on_floor:
		velocity.y = JUMP_VELOCITY
	
	var overlaps = aoe.get_overlapping_bodies()
	
	# Change behaviour based on floor
	acceleration = 0
	on_floor = false
	for overlap in overlaps:
		if "get_pipe_centre" in overlap:
			if quarter_pipe_direction == 0:
				if direction.x > 0:
					quarter_pipe_direction = -1
				else:
					quarter_pipe_direction = 1
			acceleration = 0
			var c : Vector2 = overlap.get_pipe_centre()
			var tangent_angle = c.angle_to_point(self.global_position) + PI/2.0
			direction.x = cos(tangent_angle)
			direction.y = sin(tangent_angle)
			direction = direction.normalized()
			direction *= quarter_pipe_direction
			on_floor = true
			print("PIPE")
		elif "acceleration_factor" in overlap:
			on_floor = true
			acceleration = overlap.acceleration_factor
			velocity.y = 0
			direction.y = 0
			direction.x = sign(direction.x)
			gravity_effect = Vector2.ZERO
	
	if !on_floor:
		quarter_pipe_direction = 0
	else:
		gravity_effect = Vector2.ZERO
	
	velocity = direction * speed + gravity_effect
	speed = speed + acceleration
	
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	
	position = position + velocity * delta
