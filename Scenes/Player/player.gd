extends CharacterBody2D


const JUMP_VELOCITY = -400.0

@onready var aoe = $AreaOfEffect

var direction : Vector2 = Vector2(1, 0);
var acceleration = 0
var speed = 1

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		velocity.y = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity += direction * speed
	
	var overlaps = aoe.get_overlapping_bodies()
	
	# Change behaviour based on floor
	acceleration = 0
	for overlap in overlaps:
		if "acceleration_factor" in overlap:
			acceleration = overlap.acceleration_factor

	speed = speed + sign(direction.x) * acceleration
	print(speed)

	move_and_slide()
