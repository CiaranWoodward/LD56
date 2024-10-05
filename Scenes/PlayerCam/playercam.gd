extends Camera2D

#Point to player to access coordinates:
@onready var player = $"../Player"

#Separate smoothing rates for x and y axes:
@export var smooth_x : float = 0.3
@export var smooth_y : float = 0.2

func _physics_process(delta: float) -> void:
	#Linear interpolation in 2 dimensions to smooth camera movement:
	position = Vector2(lerp(position.x, player.position.x, smooth_x), lerp(position.y, player.position.y, smooth_y))
