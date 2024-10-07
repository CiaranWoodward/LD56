extends Camera2D

#Point to player to access coordinates:
@onready var player = $"../Player"

#Separate smoothing rates for x and y axes:
@export var smooth_x : float = 0.3
@export var smooth_y : float = 0.2

@export var cam_frozen : bool = 0 # Freeze camera in position

@export var screen_shake_decay = 0.85  # How quickly the shaking stops [0, 1].
@export var screen_shake_max_offset = Vector2(20, 20)  # Maximum hor/ver shake in pixels.
@export var screen_shake_max_roll = 0.03  # Maximum rotation in radians (use sparingly).

@onready var screen_shake_start_position = position
@onready var screen_shake_noise = FastNoiseLite.new()

@onready var cam_floor_offset := 0

var screen_shake_noise_y = 0

var screen_shake_childhood_trauma = 0.0 # Base level of trauma
var screen_shake_trauma = 0.0  # Current shake strength.
var screen_shake_trauma_power = 2  # Trauma exponent. Use [2, 3].
var screen_shake_offset: Vector2 = Vector2.ZERO
var screen_shake_rotation_offset: float = 0.0

var unshaken_position: Vector2
var unshaken_rotation_degrees: float

func _ready():
	screen_shake_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	screen_shake_noise.seed = randi()
	screen_shake_noise.frequency = 0.15
	screen_shake_noise.fractal_octaves = 2
	unshaken_position = position
	unshaken_rotation_degrees = rotation_degrees

#Linear interpolation in 2 dimensions to smooth camera movement:
func _physics_process(delta: float) -> void:
	if !cam_frozen :
		unshaken_position = Vector2(lerp(position.x, player.position.x, smooth_x), lerp(position.y, player.position.y, smooth_y))
		_shake(delta)
		position = unshaken_position + screen_shake_offset
		rotation_degrees = unshaken_rotation_degrees + rad_to_deg(screen_shake_rotation_offset)

#Update smoothing coefficients:
func cam_smooth(x: float, y: float) :
	smooth_x = x
	smooth_y = y

#Gradual change of zoom:
func cam_zoom(x: float, y: float, rate: float) :
	var tween = create_tween()
	tween.tween_property($".","zoom",Vector2(x,y),rate).from(zoom)

#Gradual change of camera angle in degrees, rotate QTE prompts to match
func cam_rotate(angle_degrees: float, rate: float) :
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property($".","unshaken_rotation_degrees",angle_degrees, rate).from(unshaken_rotation_degrees)
	tween2.tween_property($"../Player/QTE","rotation_degrees",angle_degrees, rate).from(rotation_degrees)

func screen_shake_add_permanant_trauma(amount: float):
	screen_shake_childhood_trauma = min(screen_shake_childhood_trauma + amount, 0.6)

func screen_shake_add_trauma(amount : float):
	screen_shake_trauma = min(screen_shake_trauma + amount, 1.0)

func _shake(delta: float):
	if !screen_shake_trauma && !screen_shake_childhood_trauma:
		screen_shake_offset = Vector2.ZERO
		screen_shake_rotation_offset = 0
		return
	screen_shake_trauma = max(screen_shake_trauma - screen_shake_decay * delta, 0)
	var screen_shake_working_trauma = min(screen_shake_trauma + screen_shake_childhood_trauma, 1.0)
	var amt = pow(screen_shake_working_trauma, screen_shake_trauma_power)
	screen_shake_noise_y += 1
	screen_shake_rotation_offset = screen_shake_max_roll * amt * screen_shake_noise.get_noise_2d(0,screen_shake_noise_y)
	screen_shake_offset.x = screen_shake_max_offset.x * amt * screen_shake_noise.get_noise_2d(1000,screen_shake_noise_y)
	screen_shake_offset.y = screen_shake_max_offset.y * amt * screen_shake_noise.get_noise_2d(2000,screen_shake_noise_y)

func cam_floor(position) :
	limit_bottom = position+cam_floor_offset
