extends Node2D

@export var acceleration_factor = -500
@onready var particles = get_node("Visuals/DestructionParticles")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	$Visuals/Particles/TraceParticles.emitting = true
	$Visuals/Particles/SmokeParticles.emitting = true
	$Visuals/Particles/FireParticles.emitting = true
	
	$Area2D/CollisionShape2D.disabled = true
	var t = get_tree().create_tween()
	t.tween_property($Visuals/Sprite2D, "modulate", Color.TRANSPARENT, 0.2)
	t.tween_interval(0.8)
	t.tween_callback(queue_free)
	
