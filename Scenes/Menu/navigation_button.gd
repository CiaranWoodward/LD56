class_name NavigationButton
extends FxButton

@export var target_view: String

var _menu: Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	_menu = $"/root/Menu"
	# Connect the button's pressed signal to the _on_start_button_pressed function
	pressed_fx.connect(_navigate)

# Called when the button is pressed
func _navigate() -> void:
	_menu.change_view(target_view)
