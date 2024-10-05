extends Node2D

@export var min_dist_x : int = 25
@export var min_dist_y : int = 25
@export var max_dist_x : int = 100
@export var max_dist_y : int = 100

var qte_keys = ["W","A","S","D"]
var current_key : String
var prev_key    : String
var qte_active  : bool = false
	
#Set the prompt texture for the QTE key:
func _on_player_prompt_set_texture(path) -> void:
	$Sprite2D.texture = load(path)
	
#End QTE on timeout:
func _on_timer_qte_timeout() -> void:
	get_tree().call_group('Player',"end_qte")

#Start new QTE
func start_qte(time : float) :
	if !qte_active :
		var rng  := RandomNumberGenerator.new()
		
		#Position prompt randomly around player:
		var x : int = rng.randi_range(min_dist_x,max_dist_x)
		var y : int = rng.randi_range(min_dist_y,max_dist_y)
		position = Vector2(x,y)
		
		#Randomly select key, one reroll to reduce repeats
		current_key = qte_keys[rng.randi_range(0,3)]
		if current_key == prev_key :
			current_key = qte_keys[rng.randi_range(0,3)]
		prev_key = current_key
			
		$Sprite2D.texture = load("res://icon.svg")
		
		#Prompt user for key, start countdown, enable checking for input
		qte_active = true
		print("Press " + current_key + "!")
		$TimerQTE.start(time)
	
	
#Disable checking for input and signal result:
func end_qte(passed: bool = false) :
	
	qte_active = false
	
	if passed :
		#emit_signal("qte_passed")
		print("QTE PASSED!\n")
	else :
		#emit_signal("qte_failed")
		print("QTE FAILED\n")
		
	#Clear Texture
	$Sprite2D.texture = load("null")
		
	
	
#End QTE on input, check result:
func _input(event) :
	if qte_active and Input.is_anything_pressed() :
		if event.is_action_pressed(current_key) :
			end_qte(true)
		else :
			end_qte()
