extends CharacterBody3D

#tweaks
const THRESHOLD_WHISPER=-50.0
const THRESHOLD_TALK =-30.0
const THRESHOLD_SCREAM=-10.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY =0.003

#colors
const COLOR_EMBER=Color(1.0,0.4,0.0)
const COLOR_TORCH=Color(1.0,0.9,0.0)
const COLOR_FLARE=Color(1.0,1.0,1.0)

@onready var camera =$Camera3D
@onready var chest_light=$Camera3D/OmniLight3D

var gravity =ProjectSettings.get_setting("physics/3d/default_gravity")
var time_passed=0.0 #flicker
func _ready():
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x*MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y*MOUSE_SENSITIVITY)
		camera.rotation.x=clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))

@warning_ignore("unused_parameter")
func _process(delta):
	time_passed+=delta
	var mic_bus_index=AudioServer.get_bus_index("MicInput")
	var volume_db=AudioServer.get_bus_peak_volume_left_db(mic_bus_index,0)
	
	var target_energy=0.0
	var target_range=0.0
	var target_color=Color.BLACK
	
	if volume_db> THRESHOLD_SCREAM:
		target_range=20.0
		target_color=COLOR_FLARE
		if int(time_passed*20)%2==0:
			target_energy=10.0
		else:
			target_energy=0.5
	elif volume_db>THRESHOLD_TALK:
		target_range=8.0
		target_color=COLOR_TORCH
		target_energy=2.0
		
	elif volume_db>THRESHOLD_WHISPER:
		target_range=30.0
		target_color=COLOR_EMBER
		target_energy=1.0+(sin(time_passed*10)*0.5)
	else:
		target_energy=0.0
		target_range=0.0
		target_color=Color.BLACK
		
	
	chest_light.light_energy=lerp(chest_light.light_energy,target_energy,0.1)
	chest_light.omni_range=lerp(chest_light.omni_range,target_range,0.1)
	
	if target_energy>0.1:
		chest_light.light_color=target_color
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
