extends StaticBody2D

@onready var centre_node = $Centre

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_pipe_centre()-> Vector2:
	return centre_node.global_position
