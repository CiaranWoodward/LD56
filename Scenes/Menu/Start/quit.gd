class_name QuitButton
extends FxButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	pressed_fx.connect(_quit_game)
	
func _quit_game() -> void:
	get_tree().quit()
