extends Area2D

@export var cam_floor_offset : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group('Camera',"cam_floor",$CollisionShape2D.global_position.y)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	$"/root/Menu".restart_level_from_game()

func _on_body_entered(body: Node2D) -> void:
	$"/root/Menu".restart_level_from_game()
