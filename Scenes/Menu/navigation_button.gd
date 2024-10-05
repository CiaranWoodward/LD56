class_name NavigationButton
extends FxButton

@export var current_page: String
@export var target_page: String

const menu_buttons = "/root/Menu/CanvasLayer/MarginContainer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# Connect the button's pressed signal to the _on_start_button_pressed function
	pressed_fx.connect(_navigate)

# Called when the button is pressed
func _navigate() -> void:
	var current_control = get_node(menu_buttons).get_node(current_page) as Control
	if current_control:
		current_control.hide()
		
	var target_control = get_node(menu_buttons).get_node(target_page) as Control
	if target_control:
		target_control.show()
