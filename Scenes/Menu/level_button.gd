class_name LevelButton
extends FxButton

@export var level: PackedScene = null

var _menu: Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	_menu = $"/root/Menu"
	pressed_fx.connect(_on_level_pressed)

# Called when the button is pressed
func _on_level_pressed() -> void:
	if is_instance_valid(level):
		_menu.play_level(level)
	else:
		_menu.change_view("")
		_menu.un_pause()
