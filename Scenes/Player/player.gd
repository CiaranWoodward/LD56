extends CharacterBody2D

const JUMP_VELOCITY = -400.0

@export var MAX_SPEED = 800

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
var speed = 20
var on_floor = false
var quarter_pipe_direction = 0
var temp_ignore_bodies : Array = []

#QTE variables:
var qte_keys = ["W","A","S","D"]
var current_key : String
var prev_key    : String
var qte_active  : int = 0

func _physics_process(delta: float) -> void:
	var overlaps : Array = aoe.get_overlapping_bodies()
	acceleration = 0
	
	if player_state == PLAYER_STATE.IN_AIR:
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
		if ! exit_vec.is_zero_approx():
			direction = exit_vec
			force_leave()
	
	if player_state == PLAYER_STATE.ON_FLOOR:
		if current_scenery in overlaps:
			acceleration = current_scenery.acceleration_factor
			velocity.y = 0
			direction.y = 0
			direction.x = sign(direction.x)
			set_global_position(Vector2(global_position.x, current_scenery.floor_y()))
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
			force_leave()
			join_floor(overlap) 
	
	if speed > MAX_SPEED:
		speed = MAX_SPEED
	speed = speed + acceleration
	
	velocity = direction * speed + gravity_effect
	
	position = position + velocity * delta

func current_movement_direction():
	return velocity.normalized()

func force_leave():
	match (player_state):
		PLAYER_STATE.ON_FLOOR:
			leave_floor()
		PLAYER_STATE.ON_QUARTER_PIPE:
			leave_quarter_pipe()
		PLAYER_STATE.IN_AIR:
			pass
		_:
			print(PLAYER_STATE.keys()[player_state] + ": Cannot leave!!!")

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
	print("Player: " + PLAYER_STATE.keys()[player_state] + " -> " + PLAYER_STATE.keys()[new_state])
	player_state = new_state

func leave_quarter_pipe():
	change_player_state(PLAYER_STATE.IN_AIR)
	temp_ignore_bodies.append(current_scenery)
	current_scenery = null

func join_quarter_pipe(qpipe : QuarterPipe):
	quarter_pipe_direction = qpipe.get_direction(global_position, current_movement_direction())
	change_player_state(PLAYER_STATE.ON_QUARTER_PIPE)
	current_scenery = qpipe

func leave_floor():
	change_player_state(PLAYER_STATE.IN_AIR)
	current_scenery = null

func join_floor(floor : Floor):
	change_player_state(PLAYER_STATE.ON_FLOOR)
	current_scenery = floor

#Prompt user for key, start countdown, enable checking for input
func start_qte(key : String, time : float) :
	
	qte_active = 1
	print("Press " + key + "!")
	$TimerQTE.start(time)
	
	
#Disable checking for input and signal result:
func end_qte(passed: bool = false) :
	
	qte_active = 0
	
	if passed :
		emit_signal("qte_passed")
		print("QTE PASSED!\n")
	else :
		emit_signal("qte_failed")
		print("QTE FAILED\n")
	
#End QTE on timeout:
func _on_timer_qte_timeout() -> void:
	end_qte()
	
#End QTE on input, check result:
func _input(event) :
	if qte_active ==1 and Input.is_anything_pressed() :
		if event.is_action_pressed(current_key) :
			end_qte(true)
		else :
			end_qte()
	
