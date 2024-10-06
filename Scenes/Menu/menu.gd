class_name Menu
extends Control

@export var views: Array[Control]

@export var hud_scene: PackedScene

@export var canvas: CanvasLayer

const _multipliers: Array[float] = [1, 1.25, 1.5, 2, 4, 6, 10]

var _active_level: Node

var _player: Player

var _active_scene: PackedScene

var _hud: Hud

var _level_score: int

var _total_score: int

var _multiplier: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_hud = hud_scene.instantiate()
	add_child(_hud)
	_hud.should_display(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_handle_esc()
		
	if is_instance_valid(_player) and is_in_game():
		update_speed(_player.speed)

####
#### Menu shit be careful if you change this! (sorry)
####

func _handle_esc() -> void:
	var current_view = _get_view()
	if current_view == "NextLevel":
		pass
		
	if current_view == "":
		change_view("Start")
		if is_instance_valid(_active_level):
			# pause
			get_tree().root.remove_child(_active_level)
			_hud.should_display(false)
	elif current_view == "Start":
		if is_instance_valid(_active_level):
			change_view("")
			un_pause()
	else:
		change_view("Start")
		
func un_pause():
	if get_tree().root.get_children().find(_active_level) == -1:
		get_tree().root.add_child(_active_level)
		_hud.should_display(true)
		change_view("")
	
func play_level(scene: PackedScene) -> void:
	change_view("")
	if is_instance_valid(_active_level) and is_instance_valid(_active_scene) and scene == _active_scene:
		un_pause()
		
	if is_instance_valid(_active_level):
		_active_level.queue_free()
		
	_active_scene = scene
	_active_level = _active_scene.instantiate()
	restart_level()
	get_tree().root.add_child(_active_level)
	_hud.should_display(true)
	_hud._set_level_name(_active_level)
	
func _get_view() -> String:
	for view in views:
		if view.visible:
			return view.name
	return ""
	
func is_in_game() -> bool:
	return is_instance_valid(_active_level)
	
func change_view(name: String) -> void:
	if name == "":
		canvas.hide()
	else:
		canvas.show()
	for view in views:
		if view.name == name:
			view.show()
		else:
			view.hide()

####
#### Game Controls
####

func update_speed(value: int):
	_hud._set_speed(String.num(value / 40))
			
func add_score(delta_score: int):
	_level_score += delta_score * _multipliers[_multiplier]
	_hud._set_score(_level_score)
	
func increase_multiplier():
	if _multiplier < _multipliers.size() - 1:
		_multiplier += 1
	_hud._set_multiplier(_multipliers[_multiplier])
	
func reset_score():
	_level_score = 0
	_hud._set_score(_level_score)
	
func reset_multiplier():
	_multiplier = 0
	_hud._set_multiplier(_multipliers[_multiplier])
	
func restart_level():
	if is_instance_valid(_active_level) and is_instance_valid(_active_scene):
		_active_level = _active_scene.instantiate()
		_player = _active_level.find_child("Player")
		reset_score()
		reset_multiplier()
		un_pause()

func complete_level(next_level: PackedScene = null):
	_total_score += _level_score
	change_view("NextLevel")
	reset_multiplier()
	pass
	
