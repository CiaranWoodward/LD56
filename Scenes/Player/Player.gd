class_name Player

extends CharacterBody2D

const JUMP_VELOCITY = -300.0

@export var MAX_SPEED = 1200
@export var JUMP_TIME = 0.6
@export var BOUNCINESS = 0.5

@onready var aoe = $AreaOfEffect

enum PLAYER_STATE {
	IN_AIR,
	IN_QPIPE_AIR_TRICKS,
	ON_FLOOR,
	ON_QUARTER_PIPE,
}

var current_scenery = null
var player_state : PLAYER_STATE = PLAYER_STATE.IN_AIR
var gravity_effect : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2(-1, 0);
var acceleration = 0
var acceleration_penalty : float = 0
var acceleration_penalty_time : float = 0
var speed = 20
var on_floor = false
var quarter_pipe_direction = 0
var temp_ignore_bodies : Array = []
var gravity_disabled : bool = false
var jump_over_timeout : Tween

func _ready() -> void:
	jump_over_timeout = get_tree().create_tween()

func _physics_process(delta: float) -> void:
	var overlaps : Array = aoe.get_overlapping_bodies()
	acceleration = 0
	
	if player_state == PLAYER_STATE.IN_AIR:
		if !gravity_disabled:
			gravity_effect += get_gravity() * delta
	else:
		gravity_effect = Vector2.ZERO
	
	if player_state == PLAYER_STATE.ON_QUARTER_PIPE:
		var c : Vector2 = current_scenery.get_pipe_centre()
		var tangent_angle = c.angle_to_point(self.global_position) + PI/2.0
		direction.x = cos(tangent_angle)
		direction.y = sin(tangent_angle)
		direction = direction.normalized() * quarter_pipe_direction
		var pipe_centre = current_scenery.get_pipe_centre()
		global_position = (global_position - pipe_centre).normalized() * current_scenery.get_radius() + pipe_centre
		var exit_vec : Vector2 = current_scenery.get_exit_vector(quarter_pipe_direction, current_movement_direction())
		$Visual.rotation = direction.angle()
		$Visual.scale.x = 1
		$Visual.scale.y = -quarter_pipe_direction
		var max_bounds : Area2D = current_scenery.get_max_bounds()
		if ! exit_vec.is_zero_approx():
			if speed < 500 && exit_vec.y < -0.5:
				quarter_pipe_direction *= -1
			else:
				direction = exit_vec
				force_leave()
		elif max_bounds not in aoe.get_overlapping_areas():
			direction = current_movement_direction()
			force_leave()
	
	if player_state == PLAYER_STATE.ON_FLOOR:
		if current_scenery in overlaps:
			if (acceleration_penalty_time > 0):
				acceleration_penalty_time -= delta
			else:
				acceleration_penalty = 1
				
			acceleration = acceleration_penalty * current_scenery.acceleration_factor
			velocity.y = 0
			direction.y = 0
			direction.x = sign(direction.x)
			set_global_position(Vector2(global_position.x, current_scenery.floor_y()))
			$Visual.rotation = 0
			$Visual.scale.y = 1
			$Visual.scale.x = sign(direction.x)
		else:
			force_leave()

	# Handle the temporary ignores list, which stop you immediately snapping back onto the same
	# scenery
	var temp_ignore_bodies_more_temporary = temp_ignore_bodies
	temp_ignore_bodies = []
	for ib in temp_ignore_bodies_more_temporary:
		if ib in overlaps:
			overlaps.erase(ib)
			temp_ignore_bodies.append(ib)
	
	# Change behaviour based on floor
	for overlap in overlaps:
		if overlap is QuarterPipe && can_change_player_state(PLAYER_STATE.ON_QUARTER_PIPE):
			force_leave()
			join_quarter_pipe(overlap)
		elif overlap is Floor && can_change_player_state(PLAYER_STATE.ON_FLOOR):
			if overlap.is_in_landing_plane($CollisionBottom.global_position):
				force_leave()
				join_floor(overlap)
			else:
				var collision = move_and_collide(velocity * delta, true)
				if collision:
					var normal = collision.get_normal()
					direction = direction.bounce(normal)
					speed *= BOUNCINESS
					if normal.y > 0:
						gravity_effect.y -= gravity_effect.y * abs(normal.y) * 1.5
					print("bounce")
	
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	speed = speed + acceleration
	
	if player_state == PLAYER_STATE.ON_FLOOR:
		if Input.is_action_just_pressed("jump"):
			force_leave()
			temp_ignore_bodies = overlaps
			gravity_effect.y = JUMP_VELOCITY
			gravity_disabled = true
			jump_over_timeout = get_tree().create_tween()
			jump_over_timeout.tween_property(self, "gravity_disabled", false, JUMP_TIME)
	
	if Input.is_action_just_released("jump"):
		cancel_jump()
	
	var prev_velocity = velocity
	velocity = direction * speed + gravity_effect
	if player_state == PLAYER_STATE.IN_AIR && (sign(prev_velocity.y) < sign(velocity.y)):
		temp_ignore_bodies.clear()
	
	position = position + velocity * delta
	#move_and_collide(velocity * delta, false)
	
func cancel_jump():
	if gravity_disabled:
		jump_over_timeout.stop()
		gravity_disabled = false

func current_movement_direction():
	return velocity.normalized()

func force_leave():
	match (player_state):
		PLAYER_STATE.ON_FLOOR:
			leave_floor()
		PLAYER_STATE.ON_QUARTER_PIPE:
			leave_quarter_pipe()
		PLAYER_STATE.IN_AIR:
			cancel_jump()
		_:
			pass#print(PLAYER_STATE.keys()[player_state] + ": Cannot leave!!!")

func can_change_player_state(new_state: PLAYER_STATE) -> bool:
	if new_state == player_state:
		return false
	match (new_state):
		PLAYER_STATE.ON_FLOOR:
			return player_state == PLAYER_STATE.IN_AIR
		PLAYER_STATE.ON_QUARTER_PIPE:
			return true
		PLAYER_STATE.IN_AIR:
			return true
	return true

func change_player_state(new_state: PLAYER_STATE):
	#print("Player: " + PLAYER_STATE.keys()[player_state] + " -> " + PLAYER_STATE.keys()[new_state])
	player_state = new_state

func leave_quarter_pipe():
	change_player_state(PLAYER_STATE.IN_AIR)
	temp_ignore_bodies.append(current_scenery)
	current_scenery = null

func join_quarter_pipe(qpipe : QuarterPipe):
	quarter_pipe_direction = qpipe.get_direction(global_position, current_movement_direction())
	speed *= qpipe.get_speed_component_at_entrance(global_position, current_movement_direction())
	change_player_state(PLAYER_STATE.ON_QUARTER_PIPE)
	current_scenery = qpipe

func leave_floor():
	change_player_state(PLAYER_STATE.IN_AIR)
	current_scenery = null

func join_floor(floor : Floor):
	change_player_state(PLAYER_STATE.ON_FLOOR)
	current_scenery = floor

func decelerate(deceleration_factor : int, acceleration_penalty : float, acceleration_penalty_time : float):
	if speed <= deceleration_factor:
		speed = ceil(speed * 0.1)
	else: speed -= deceleration_factor
	
	self.acceleration_penalty = acceleration_penalty
	self.acceleration_penalty_time = acceleration_penalty_time
