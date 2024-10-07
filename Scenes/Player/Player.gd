class_name Player

extends CharacterBody2D

@export var JUMP_INITIAL_VELOCITY = -800.0
@export var JUMP_FINAL_VELOCITY = -200.0

@export var MAX_SPEED = 1200
@export var JUMP_TIME = 0.6
@export var BOUNCINESS = 0.5
@export var PUSH_MAX_SPEED = 400
@export var PUSH_ACCELERATION = 4
@export var BRAKE_DECELERATION = 20
@export var GRIND_SHAKE = 0.4
@export var WILE_E_COYOTE_TIME = 0.3
@export var WILE_E_COYOTE_Y_THRESHOLD = -0.2
@export var GRIND_THRESHOLD = 0.4

@export var TARGET_SPEED = 1150
@export var TRICK_POINTS = 5
@export var TRICK_PENALTY = 50
@export var TRICK_SPEED_MOD = 10

@onready var aoe = $AreaOfEffect
@onready var anim_sm : AnimationNodeStateMachinePlayback = $Visual/PlayerBody/MovementState["parameters/playback"]

enum PLAYER_STATE {
	IN_AIR,
	IN_QPIPE_AIR_TRICKS,
	ON_FLOOR,
	ON_QUARTER_PIPE,
	ON_THIRD_PIPE,
	ON_GRIND_RAIL,
	ON_RAMP
}

var current_scenery = null
var player_state : PLAYER_STATE = PLAYER_STATE.IN_AIR
var gravity_effect : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2(-1, 0);
var acceleration = 0
var acceleration_penalty : float = 0
var acceleration_penalty_time : float = 0
var speed = 20
var currently_braking = false
var ignore_brakes : bool = false
var on_floor = false
var quarter_pipe_direction = 0
var temp_ignore_bodies : Array = []
var gravity_disabled : bool = false
var jumping : bool = false
var jump_over_timeout : Tween
var grind_rotation_tween : Tween

var quarterpipe_tricks : int = 0
var trick_speed_boost  : int = 0

var ascension : bool = 0 # My people need me

#Transition in air -> any surface
signal landed

func _ready() -> void:
	jump_over_timeout = get_tree().create_tween()
	grind_rotation_tween = get_tree().create_tween()

func _physics_process(delta: float) -> void:
	var overlaps : Array = aoe.get_overlapping_bodies()
	acceleration = 0
		
	if player_state == PLAYER_STATE.IN_AIR:
		if Input.is_action_just_pressed("jump") and quarterpipe_tricks == 0:
			get_tree().call_group('QTE',"start_qte",1,3,TRICK_POINTS,false)
		if !gravity_disabled:
			gravity_effect += get_gravity() * delta
			if gravity_effect.y < JUMP_FINAL_VELOCITY:
				#Double gravity while trying to stop jumping but still rising fast
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
	
	# I copy-pasted this from quarter_pipe with slight mods (sorry)
	if player_state == PLAYER_STATE.ON_THIRD_PIPE:
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
			direction = exit_vec
			force_leave()
		elif max_bounds not in aoe.get_overlapping_areas():
			direction = current_movement_direction()
			force_leave()
	
	if player_state == PLAYER_STATE.ON_GRIND_RAIL:
		if current_scenery in overlaps:
			var grail : GrindRail = current_scenery.get_parent()
			var newparams = grail.get_current_direction_and_position(global_position, current_movement_direction())
			var newdir = newparams[0]
			var newpos = newparams[1]
			if newdir == Vector2.ZERO:
				force_leave()
			else:
				direction = newdir
				global_position = newpos
				var yscale = sign(direction.x)
				if yscale == 0: yscale = 1
				rotate_to(direction.angle(), yscale != $Visual.scale.y)
				$Visual.scale.x = 1
				$Visual.scale.y = yscale
		else:
			force_leave()
	
	if player_state == PLAYER_STATE.ON_FLOOR:
		var best_floor = _find_closest_floor(overlaps)
		if is_instance_valid(best_floor):
			current_scenery = best_floor
		if current_scenery in overlaps:
			if (acceleration_penalty_time > 0):
				acceleration_penalty_time -= delta
			else:
				acceleration_penalty = 1
				
			acceleration = acceleration_penalty * current_scenery.acceleration_factor
			velocity.y = 0
			direction.y = 0
			var dirx = sign(direction.x)
			if dirx == 0: dirx = 1
			direction.x = dirx
			set_global_position(Vector2(global_position.x, current_scenery.floor_y()))
			$Visual.rotation = 0
			$Visual.scale.y = 1
			$Visual.scale.x = dirx
		else:
			force_leave()
			
	if player_state == PLAYER_STATE.ON_RAMP:
		handle_on_ramp_player_state(overlaps)

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
		if overlap is QuarterPipe && can_change_player_state(PLAYER_STATE.ON_QUARTER_PIPE, overlap):
			force_leave()
			join_quarter_pipe(overlap)
		if overlap is ThirdPipe && can_change_player_state(PLAYER_STATE.ON_THIRD_PIPE, overlap):
			force_leave()
			join_third_pipe(overlap)
		elif overlap is GrindRailBody && can_change_player_state(PLAYER_STATE.ON_GRIND_RAIL, overlap):
				force_leave()
				join_grind_rail(overlap)
		elif overlap is Floor && can_change_player_state(PLAYER_STATE.ON_FLOOR, overlap):
			if overlap.is_in_landing_plane($CollisionBottom.global_position):
				force_leave()
				join_floor(overlap)
			else:
				maybe_bounce(delta)
		elif overlap is Ramp && can_change_player_state(PLAYER_STATE.ON_RAMP, overlap):
			if overlap.is_in_landing_plane($CollisionBottom.global_position):
				force_leave()
				join_ramp(overlap)
			else:
				maybe_bounce(delta)
		elif overlap is Wall:
			maybe_bounce(delta)

	if is_pushing():
		acceleration = max(acceleration, PUSH_ACCELERATION)

	if speed > MAX_SPEED:
		speed = MAX_SPEED
	speed = speed + acceleration
	
	if player_state == PLAYER_STATE.ON_FLOOR or player_state == PLAYER_STATE.ON_RAMP:
		if Input.is_action_pressed("Brake") and not ignore_brakes:
			handle_braking()
		
		if Input.is_action_just_released("Brake"):
			currently_braking = false
			ignore_brakes = false
	
	if player_state == PLAYER_STATE.ON_FLOOR or player_state == PLAYER_STATE.ON_GRIND_RAIL or player_state == PLAYER_STATE.ON_RAMP:
		
		if Input.is_action_just_pressed("jump"):
			force_leave()
			anim_sm.start("JumpUp")
			temp_ignore_bodies = overlaps
			gravity_effect.y = JUMP_INITIAL_VELOCITY
			disable_gravity(JUMP_TIME)
			jump_over_timeout.parallel().tween_property(self, "gravity_effect", Vector2(0, JUMP_FINAL_VELOCITY), JUMP_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			jumping = true
	
	if Input.is_action_just_released("jump") && jumping:
		cancel_jump()
	
	var prev_velocity = velocity
	if ascension :
		velocity = Vector2(0,-200)
	else :
		velocity = direction * speed + gravity_effect
		
	if player_state == PLAYER_STATE.IN_AIR && (sign(prev_velocity.y) < sign(velocity.y)):
		temp_ignore_bodies.clear()
	
	#position = position + velocity * delta
	var collision = move_and_collide(velocity * delta, false)
	if collision:
		direction = direction.slide(collision.get_normal()).normalized()

func disable_gravity(jump_time: float):
	gravity_disabled = true
	jump_over_timeout = get_tree().create_tween()
	jump_over_timeout.tween_property(self, "gravity_disabled", false, jump_time)
	print("Disabled gravity for " + str(jump_time))

func rotate_to(rot, instant=false):
	if instant:
		grind_rotation_tween.kill()
		$Visual.rotation = rot
	else:
		grind_rotation_tween = get_tree().create_tween()
		rot = lerp_angle($Visual.rotation, rot, 1)
		grind_rotation_tween.tween_property($Visual, "rotation", rot, 0.1)

func _find_closest_floor(overlaps : Array):
	var best_distance_sq = INF
	var best_floor = null
	for overlap in overlaps:
		if overlap is Floor:
			if overlap.floor_y() < global_position.y:
				continue
			var dsq = global_position.distance_squared_to(overlap.global_position)
			if dsq < best_distance_sq:
				best_distance_sq = dsq
				best_floor = overlap
	return best_floor

func maybe_bounce(delta : float):
	var collision = move_and_collide(velocity * delta, true)
	if collision:
		var normal = collision.get_normal()
		direction = direction.bounce(normal)
		speed *= BOUNCINESS
		if normal.y > 0:
			gravity_effect.y -= gravity_effect.y * abs(normal.y) * 1.5
		#print("bounce")

func cancel_jump():
	jumping = false
	if gravity_disabled:
		jump_over_timeout.stop()
		gravity_disabled = false

func is_pushing() -> bool:
	return speed < PUSH_MAX_SPEED && player_state != PLAYER_STATE.IN_AIR

func is_grinding() -> bool:
	return player_state == PLAYER_STATE.ON_GRIND_RAIL

func is_in_air() -> bool:
	return player_state == PLAYER_STATE.IN_AIR

func current_movement_direction():
	return velocity.normalized()

func force_leave():
	match (player_state):
		PLAYER_STATE.ON_FLOOR:
			leave_floor()
		PLAYER_STATE.ON_QUARTER_PIPE:
			leave_quarter_pipe()
		PLAYER_STATE.ON_THIRD_PIPE:
			leave_third_pipe()
		PLAYER_STATE.ON_RAMP:
			leave_ramp()
		PLAYER_STATE.IN_AIR:
			cancel_jump()
		PLAYER_STATE.ON_GRIND_RAIL:
			leave_grind_rail()
		_:
			print(PLAYER_STATE.keys()[player_state] + ": Cannot leave!!!")

func can_change_player_state(new_state: PLAYER_STATE, overlap) -> bool:
	if new_state == player_state:
		return false
	match (new_state):
		PLAYER_STATE.ON_FLOOR:
			return player_state == PLAYER_STATE.IN_AIR
		PLAYER_STATE.ON_GRIND_RAIL:
			var rail : GrindRail = overlap.get_parent()
			if player_state == PLAYER_STATE.IN_AIR or (player_state == PLAYER_STATE.ON_FLOOR && rail.snap_to_from_floor):
				var prev_direction = current_movement_direction()
				var new_direction = rail.get_current_direction_and_position(global_position, prev_direction)[0]
				var dot = new_direction.dot(prev_direction)
				#print("Grind dot: " + str(dot))
				return dot > GRIND_THRESHOLD
		PLAYER_STATE.ON_QUARTER_PIPE:
			return true
		PLAYER_STATE.ON_THIRD_PIPE:
			return true
		PLAYER_STATE.IN_AIR:
			return true
		PLAYER_STATE.ON_RAMP:
			return true
	return false

func change_player_state(new_state: PLAYER_STATE):
	#print("Player: " + PLAYER_STATE.keys()[player_state] + " -> " + PLAYER_STATE.keys()[new_state])
	
	#Fail any in-progress tricks on landing:
	if new_state == PLAYER_STATE.IN_AIR :
		landed.emit()
		print("Boosting: " + str(trick_speed_boost))
		speed = speed + trick_speed_boost		
		trick_speed_boost = 0
		
		quarterpipe_tricks = 0
		$Audio.stop_rolling()
	
	if player_state == PLAYER_STATE.IN_AIR && gravity_effect.y > 10: 
		if new_state == PLAYER_STATE.ON_FLOOR or new_state == PLAYER_STATE.ON_RAMP or new_state == PLAYER_STATE.ON_THIRD_PIPE or new_state == PLAYER_STATE.ON_QUARTER_PIPE:
			$Audio.play_landing()
		
	player_state = new_state

func leave_quarter_pipe():
	var qpipe : QuarterPipe = current_scenery
	#qpipe.remove_collision_exception_with(self)
	change_player_state(PLAYER_STATE.IN_AIR)
	temp_ignore_bodies.append(current_scenery)
	current_scenery = null
	
	#Launching up from quarterpipe:
	if current_movement_direction().y < 0 :
		#print("speed = " + str(speed))
		if speed >= TARGET_SPEED:
			quarterpipe_fast()
		elif speed > 500:
			quarterpipe_slow()
		
		
func join_quarter_pipe(qpipe : QuarterPipe):
	quarter_pipe_direction = qpipe.get_direction(global_position, current_movement_direction())
	speed *= qpipe.get_speed_component_at_entrance(global_position, current_movement_direction())
	change_player_state(PLAYER_STATE.ON_QUARTER_PIPE)
	current_scenery = qpipe
	qpipe.add_collision_exception_with(self)
	$Audio.play_rolling(0.7)

func leave_third_pipe():
	var pipe : ThirdPipe = current_scenery
	#pipe.remove_collision_exception_with(self)
	change_player_state(PLAYER_STATE.IN_AIR)
	temp_ignore_bodies.append(current_scenery)
	current_scenery = null
	if current_movement_direction().y < WILE_E_COYOTE_Y_THRESHOLD:
		disable_gravity(WILE_E_COYOTE_TIME)

func join_third_pipe(pipe : ThirdPipe):
	quarter_pipe_direction = pipe.get_direction(global_position, current_movement_direction())
	speed *= pipe.get_speed_component_at_entrance(global_position, current_movement_direction())
	change_player_state(PLAYER_STATE.ON_THIRD_PIPE)
	current_scenery = pipe
	pipe.add_collision_exception_with(self)
	$Audio.play_rolling(0.7)

func leave_floor():
	change_player_state(PLAYER_STATE.IN_AIR)
	current_scenery = null

func join_floor(floor : Floor):
	change_player_state(PLAYER_STATE.ON_FLOOR)
	current_scenery = floor
	$Audio.play_rolling(1)

func leave_grind_rail():
	change_player_state(PLAYER_STATE.IN_AIR)
	current_scenery = null
	self.collision_layer = 1
	self.collision_mask = 2
	grind_rotation_tween.kill()
	get_tree().call_group("Camera", "screen_shake_add_permanant_trauma", -GRIND_SHAKE)
	$Audio.stop_grinding()

func join_grind_rail(grb : GrindRailBody):
	anim_sm.start("Grind")
	change_player_state(PLAYER_STATE.ON_GRIND_RAIL)
	current_scenery = grb
	self.collision_layer = 0
	self.collision_mask = 0
	get_tree().call_group("Camera", "screen_shake_add_permanant_trauma", GRIND_SHAKE)
	$Audio.stop_rolling()
	$Audio.play_grinding()

func decelerate(deceleration_factor : int, acceleration_penalty : float, acceleration_penalty_time : float):
	if speed <= deceleration_factor:
		speed = ceil(speed * 0.1)
	else: speed -= deceleration_factor
	
	self.acceleration_penalty = acceleration_penalty
	self.acceleration_penalty_time = acceleration_penalty_time

#region Ramp

func join_ramp(ramp : Ramp):
	change_player_state(PLAYER_STATE.ON_RAMP)
	current_scenery = ramp
	$Audio.play_rolling(0.7)

func leave_ramp():
	change_player_state(PLAYER_STATE.IN_AIR)
	temp_ignore_bodies.append(current_scenery)
	current_scenery = null

func handle_on_ramp_player_state(overlaps : Array):
	if current_scenery not in overlaps:
		if current_movement_direction().y < WILE_E_COYOTE_Y_THRESHOLD:
			disable_gravity(WILE_E_COYOTE_TIME)
		force_leave()
		return
	
	assert(current_scenery is Ramp)
	
	var ramp = current_scenery as Ramp
	
	var ramp_angle = ramp.global_rotation
	var ramp_vector : Vector2 = Vector2.from_angle(ramp_angle)
	
	var cdir = current_movement_direction().normalized()
	
	var dot_product = ramp_vector.dot(cdir)
	
	# If 1, continue with direction of ramp, if zero
	var direction_modifier = 1
	if dot_product < 0:
		direction_modifier = -1
	
	speed = abs(dot_product) * speed
	
	direction = Vector2.from_angle(ramp_angle)
	direction = direction.normalized() * direction_modifier
	
	$Visual.rotation = ramp_angle
	
	if current_movement_direction().y > 0:
		acceleration = ramp.acceleration_factor * (1 + direction.y)
			

#endregion RAMP

#region Braking

func handle_braking() -> void:
	currently_braking = true
	speed -= BRAKE_DECELERATION
	var twenty_degrees_in_radians = 20 * (PI/180)
	$Visual.rotation = $Visual.rotation - (sign(direction.x) * twenty_degrees_in_radians)
	
	anim_sm.start("Grind")
	
	if (speed <= 0):
		direction.x *= -1
		$Visual.scale.x = -1
		speed = 1
		currently_braking = false
		ignore_brakes = true

func is_braking() -> bool:
	return currently_braking

#endregion Braking

#Transition to next level:
func quarterpipe_fast() :
	var tween = create_tween()
	tween.tween_property(Engine,"time_scale",0.5, 2).from(1)
	get_tree().call_group('Camera',"cam_rotate",quarter_pipe_direction*90,0.5)
	get_tree().call_group('Camera',"cam_zoom",3,3,0.5)
	get_tree().call_group('Animation',"play_random_trick",1)
	await get_tree().create_timer(0.85).timeout
	
	$"../PlayerCam".cam_frozen = true
	ascension = true	
	tween.stop()
	tween.tween_property(Engine,"time_scale",1, 0.75).from(0.5)
	
	await get_tree().create_timer(1.3).timeout
	get_tree().call_group('Menu',"complete_level")
	
	
#Perform tricks above quarterpipe for speed boost:
func quarterpipe_slow() :
	var tween = create_tween()
	quarterpipe_tricks = 2
	
	#Camera and slomo effects:
	tween.tween_property(Engine,"time_scale",0.025, 0.75).from(1)
	get_tree().call_group('Camera',"cam_rotate",quarter_pipe_direction*90,0.5)
	get_tree().call_group('Camera',"cam_zoom",3,3,0.5)
	
	#Start first QTE
	get_tree().call_group('QTE',"start_qte",quarterpipe_tricks*0.8*Engine.time_scale,8,(3-quarterpipe_tricks)*TRICK_POINTS,true)


func quarterpipe_trick() :
	var tween = create_tween()
	if quarterpipe_tricks != 0 :
		quarterpipe_tricks -= 1
		#Next trick:
		get_tree().call_group('QTE',"start_qte",quarterpipe_tricks*0.8*Engine.time_scale,12,(3-quarterpipe_tricks)*TRICK_POINTS,true)
		print("tricks: " + str(quarterpipe_tricks))
	else :
		tween.tween_property(Engine,"time_scale",1, 0.75)
		get_tree().call_group('Camera',"cam_rotate",0,0.5)
		get_tree().call_group('Camera',"cam_zoom",1,1,0.5)
	
	
func _on_qte_trick_failed(combo : bool) -> void:
	if combo == false :
		trick_speed_boost = 0 - TRICK_PENALTY
		print("Total boost to apply: " + str(trick_speed_boost))
	quarterpipe_trick()
	

func _on_qte_trick_passed(trickpoints: Variant) -> void:
	print("trickpoints = " + str(trickpoints))
	trick_speed_boost = trick_speed_boost + (trickpoints * TRICK_SPEED_MOD)
	print("Total boost to apply: " + str(trick_speed_boost))
	quarterpipe_trick()


func _on_level_floor_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
