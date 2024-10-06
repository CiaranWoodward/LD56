class_name Menu
extends Control

@export var views: Array[Control]

var _active_level: Node

var _active_scene: PackedScene

var _canvas: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_canvas = $"Canvas"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		_handle_esc()
	
func _handle_esc() -> void:
	var current_view = _get_view()
	if current_view == "":
		change_view("Start")
		if is_instance_valid(_active_level):
			# pause
			get_tree().root.remove_child(_active_level)
	elif current_view == "Start":
		if is_instance_valid(_active_level):
			change_view("")
			un_pause()
	else:
		change_view("Start")
		
func un_pause():
	if get_tree().root.get_children().find(_active_level) == -1:
			get_tree().root.add_child(_active_level)
	
func play_level(scene: PackedScene) -> void:
	change_view("")
	if is_instance_valid(_active_level) and is_instance_valid(_active_scene) and scene == _active_scene:
		un_pause()
		
	if is_instance_valid(_active_level):
		_active_level.queue_free()
		
	_active_scene = scene
	_active_level = _active_scene.instantiate()
	get_tree().root.add_child(_active_level)
	
func _get_view() -> String:
	for view in views:
		if view.visible:
			return view.name
	return ""
	
func is_in_game() -> bool:
	return is_instance_valid(_active_level)
	
func change_view(name: String) -> void:
	if name == "":
		_canvas.hide()
	else:
		_canvas.show()
	for view in views:
		if view.name == name:
			view.show()
		else:
			view.hide()
