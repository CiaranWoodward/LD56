extends Camera2D

#Point to player to access coordinates:
@onready var player = $"../Player"

#Separate smoothing rates for x and y axes:
@export var smooth_x : float = 0.3
@export var smooth_y : float = 0.2

#Linear interpolation in 2 dimensions to smooth camera movement:
func _process(_delta: float) -> void:
	position = Vector2(lerp(position.x, player.position.x, smooth_x), lerp(position.y, player.position.y, smooth_y))
	
#Update smoothing coefficients:
func cam_smooth(x: float, y: float) :
	smooth_x = x
	smooth_y = y
	
#Gradual change of zoom:
func cam_zoom(x: float, y: float, rate: float) :
	var tween = create_tween()
	tween.tween_property($".","zoom",Vector2(x,y),rate).from(zoom)
	
#Gradual change of camera angle in degrees
func cam_rotate(angle_degrees: float, rate: float) :
	var tween = create_tween()
	tween.tween_property($".","rotation_degrees",angle_degrees, rate).from(rotation_degrees)
	
