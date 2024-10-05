extends Button

@export var current_scene: Node

var main_scene = preload("res://Scenes/Main/Main.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button's pressed signal to the _on_start_button_pressed function
	connect("pressed", _on_start_button_pressed)

# Called when the button is pressed
func _on_start_button_pressed() -> void:
	current_scene.queue_free()
	get_tree().root.add_child(main_scene)
	
