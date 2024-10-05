class_name SwapSceneButton
extends FxButton

@export var current_scene: String
@export var target_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	# Connect the button's pressed signal to the _on_start_button_pressed function
	pressed_fx.connect(_on_start_button_pressed)

# Called when the button is pressed
func _on_start_button_pressed() -> void:
	get_tree().root.get_node(current_scene).queue_free()
	get_tree().root.add_child(target_scene.instantiate())
