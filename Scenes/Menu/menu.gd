class_name Menu
extends Control

@export var views: Array[Control]

@export var hud_scene: PackedScene

@export var canvas: CanvasLayer

@export var levels: Array[PackedScene]

const _multipliers: Array[float] = [1, 1.25, 1.5, 2, 4, 6, 10]

var _active_level: Node

var _player: Player

var _active_scene: PackedScene

var _hud: Hud

var _level_score: int

var _total_score: int

var _multiplier: int

var _level_item_count: int

var _level: int

var _can_pause: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_can_pause = true
	_hud = hud_scene.instantiate()
	add_child(_hud)
	_hud.should_display(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc") and _can_pause:
		_handle_esc()
		
	if is_instance_valid(_player) and is_in_game():
		update_speed(_player.speed)

####
#### Menu shit be careful if you change this! (sorry)
####

func _handle_esc() -> void:
	var current_view = _get_view()
	if current_view == "NextLevel" or current_view == "EndGameScreen":
		return
		
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
	
func play_level(level: int) -> void:
	# reset score on new game+
	if level == 0:
		_total_score = 0
	_level = level
	var scene = null
	if _level >= 0:
		assert(_level < levels.size())
		scene = levels[_level]
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
	return is_instance_valid(_active_level) and not is_game_complete()
	
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
	
func add_item():
	_level_item_count += 1
			
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
	
func disable_pause():
	_can_pause = false
	
func enable_pause():
	_can_pause = true
	
func restart_level():
	if is_instance_valid(_active_level) and is_instance_valid(_active_scene):
		_active_level = _active_scene.instantiate()
		_player = _active_level.find_child("Player")
		_level_item_count = 0
		reset_score()
		reset_multiplier()
		un_pause()

func complete_level():
	_level += 1
	if is_game_complete():
		complete_game()
		return
	_total_score += _level_score
	_handle_esc()
	change_view("NextLevel")
	reset_multiplier()
	
func is_game_complete():
	return _level >= levels.size()
	
func complete_game():
	_handle_esc()
	_level = 0
	_active_scene = null
	_active_level = null
	restart_level()
	change_view("EndGameScreen")
	
