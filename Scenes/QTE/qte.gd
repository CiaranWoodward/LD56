extends Node2D

#Control where the prompt can spawn in relation to the player:
@export var min_dist_x : int = 25
@export var min_dist_y : int = 25
@export var max_dist_x : int = 100
@export var max_dist_y : int = 100

@export var anim_speed : float = 3

#Possible keys required:
var qte_keys = ["W","A","S","D"]
var current_key    : String
var prev_key       : String
var qte_active     : bool = false
var anim_running   : bool = false
var already_failed : bool = false
var landed         : bool = true
var trick_combo    : bool = false
var trick_points   : int  = 0

signal trick_failed
signal trick_passed(trick_points)
	
#Set the prompt texture for the QTE key:
func _on_player_prompt_set_texture(path) -> void:
	$Sprite2D.texture = load(path)
	
#End QTE on timeout:
func _on_timer_qte_timeout() -> void:
	#print("timed out!")
	end_qte()
	
#Start new QTE, pass in time to complete
func start_qte(time : float, speed : float, combo: bool) :
	anim_speed = speed
	#Calculate score for success:
	trick_points = (2.1-time)*10
	trick_combo  = combo
	
	#print("qte_active = " + str(qte_active))
	#print("anim_running = " + str(anim_running))
	#print("already_failed = " + str(already_failed))
	#print("combo = " + str(combo)) 
	if !qte_active and !anim_running and !already_failed :
		var rng  := RandomNumberGenerator.new()
		#print("Starting!")
		#Position prompt randomly around player:
		var x : int = rng.randi_range(min_dist_x,max_dist_x)
		var y : int = rng.randi_range(min_dist_y,max_dist_y)
		position = Vector2(x,y)
		
		#Randomly select key, one reroll to reduce repeats
		current_key = qte_keys[rng.randi_range(0,3)]
		if current_key == prev_key :
			current_key = qte_keys[rng.randi_range(0,3)]
		prev_key = current_key
			
		#Load prompt sprite:
		$Sprite2D.texture = load("res://Graphics/Prompts/Prompt_" + current_key + ".png")
		$Sprite2D.visible = true
		#print("sprite loaded")
		
		#Prompt user for key, start countdown, enable checking for input
		qte_active = true
		#print("Press " + current_key + "!")
		$TimerQTE.start(time)
		#print("timer started")
	
	
#Disable checking for input and signal result:
func end_qte(passed: bool = false) :
	#print("ending!")
	#Clear Texture
	$Sprite2D.visible = false
	if qte_active :
		qte_active = false
		if passed :
			#print("QTE PASSED!\n")
			anim_running = true
			get_tree().call_group('Animation',"play_random_trick",anim_speed)
		else :
			#print("QTE FAILED\n")
			already_failed = !trick_combo
			emit_signal("trick_failed")
			#print("Trick failed!")
			
			
	
#End QTE on input, check result:
func _input(event) :
	if qte_active and Input.is_anything_pressed() :
		if event.is_action_pressed(current_key) :
			#print("Correct key!")
			end_qte(true)
		else :
			#print("Wrong key!")
			end_qte()


func _on_tricks_animation_finished(anim_name: StringName) -> void:
	#print("Animation finished!")
	if anim_running ==  true :
		anim_running = false
		emit_signal("trick_passed",trick_points)
		print("Trick passed!")
		


func _on_player_landed() -> void:
	#print("landed!")
	landed = true
	already_failed = false
	if qte_active :
		end_qte()
		
	if anim_running :
		anim_running = false
		emit_signal("trick_failed")
		#print("Trick failed!")
		
	
