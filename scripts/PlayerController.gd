extends CharacterBody3D
#
#Movement
#region Movement
var speed
var input_dir: Vector2
var direction

var stasis := false


@export_category("Walking")
@export var WALK_SPEED = 8.0
@export var SPRINT_SPEED = 10.0
@export var FRICTION = 7.0

@export_category("Jumping")
@export var JUMP_VELOCITY = 4.5
@export var COYOTE_TIME = 0.4
@export var AIR_DRIFT = 3.0

var coyote_timer = 0.0
const FALL_GRAVITY = 12
const JUMP_GRAVITY = 7
var has_jumped = false

@export_category("Dash")
@export var DASH_FORCE := 8.0
@export var STARTUP_TIME = .02
@export var DASH_COOLDOWN = 1.0
@export var DASH_ANGLE := 1.0
var dash_timestamp : float
var dash_timer : float

var can_dash := true

 

@export_category("Camera")
@export var VERT_SENSITIVITY = 0.08
@export var SENSITIVITY = 0.10
@export var SENSITIVITY_DAMP = 40
@export var RECOIL_FORCE := 3.0
var recoils_applied := 0
#head bob
var CAMERA_START: Vector3
@export_category("View Bob")
@export var  BOB_FREQ = 2.0
@export var BOB_AMP = 0.08
@export var IDLE_EASING := .05
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

#endregion

var in_reload_mode = false

#References
#region References
@onready var head = $Head
@onready var camera:Camera3D = $Head/Camera3D
@onready var gun = $Head/Camera3D/Gun

@onready var speed_lines: Control = $SpeedLines

#endregion

#Audio
@export_category("Audio")
@export var audio_jump : AudioStreamPlayer
@export var audio_dash : AudioStreamPlayer

func  _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	CAMERA_START = camera.position
	speed = WALK_SPEED
	$SpeedLines.material.set_shader_parameter("line_density", 0.0)
#---------------------------------
#CAMERA INPUT
#---------------------------------
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY/SENSITIVITY_DAMP)
		camera.rotate_x(-event.relative.y * VERT_SENSITIVITY/SENSITIVITY_DAMP)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
#---------------------------------
#MOVEMENT
#---------------------------------
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_walk(delta)
	_dash_startup()
	_handle_headbob(delta)
	
	if velocity.length() > 9:
		$SpeedLines.material.set_shader_parameter("line_density", 1.0)
	else:
		$SpeedLines.material.set_shader_parameter("line_density", 0.0)

#region Fov
	#fov
	#var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	#var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta *8.0)
#endregion

#region Gun
	#shooting 
	if Input.is_action_just_pressed("primary_fire") || (Input.is_action_pressed("trick") && Input.is_action_pressed("primary_fire")):
		if gun.cylinder.size() > 0:
			if gun.cylinder[0] == Global.BulletType.Blast:
				velocity += camera.get_global_transform().basis.z.normalized() * (RECOIL_FORCE / (recoils_applied + 1))
		
		recoils_applied += 1
		gun.Fire()
		pass
	
	if Input.is_action_pressed("trick"):
		if Input.is_action_pressed("Q"):
			gun.Reload(Global.BulletType.Normal, "Reload")
		if  Input.is_action_pressed("E"):
			gun.Reload(Global.BulletType.Blast, "Blast_Reload")
			
#endregion

	if !stasis:
		move_and_slide()

#I should detangle these but fuck it
func _handle_walk(delta: float):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed 
			velocity.z = direction.z * speed 
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * FRICTION)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * FRICTION)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * AIR_DRIFT)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * AIR_DRIFT)

func _dash_startup():
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	if Input.is_action_just_pressed("sprint") and can_dash:
		stasis = true
		var timer := Timer.new()
		get_tree().root.add_child(timer)
		timer.one_shot = true
		timer.start(STARTUP_TIME)
		timer.timeout.connect(_handle_dash)

func _handle_dash():
	stasis = false
	# Handle sprint	
	audio_dash.play()
		
	if not is_on_floor():
		velocity.y = 0
		can_dash = false
		
		_add_dash_force(DASH_FORCE)
	else:
		_add_dash_force(DASH_FORCE*1.5)

func _handle_jump():
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and coyote_timer < COYOTE_TIME and has_jumped == false:
		velocity.y = JUMP_VELOCITY
		has_jumped = true
		audio_jump.play()

func _handle_headbob(delta: float):
	#head bob
	if is_on_floor() && input_dir.length() > .1:
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
	else:
		camera.transform.origin = camera.transform.origin.slerp(CAMERA_START, IDLE_EASING)

func _apply_gravity(delta: float):
	# Add the gravity.
	if not is_on_floor():
		#---------------------------------
		#ADD TO THE COYOTE TIMER IF PLAYER IS OFF THE FLOOR
		#---------------------------------
		if coyote_timer < COYOTE_TIME:
			coyote_timer += delta
		#---------------------------------
		#VARIABLE JUMP HEIGHT
		#---------------------------------
		if velocity.y > 0 and Input.is_action_pressed("jump") and has_jumped:
			velocity.y -= JUMP_GRAVITY * delta
		else:
			velocity.y -= FALL_GRAVITY * delta
	else:
		#---------------------------------
		#RESET COYOTE TIMER ONCE LANDED
		#---------------------------------
		if coyote_timer > 0.0:
			coyote_timer = 0.0
		#---------------------------------
		#RESET JUMP
		#---------------------------------
		if has_jumped == true:
			has_jumped = false
		
		if can_dash == false:
			can_dash = true
		
		if recoils_applied > 0:
			recoils_applied = 0

func _add_dash_force(dash_force: float):
	if input_dir.length() > .1:
		velocity += (direction + Vector3(0, DASH_ANGLE, 0)).normalized() * dash_force
	else:
		velocity += (head.transform.basis * Vector3(0, DASH_ANGLE, -1)).normalized() * dash_force

func _process(delta: float) -> void:
	if is_on_floor():
		if can_dash == false:
			can_dash = true
			print_debug("dash up")

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
#func _dash_startup

func _end_stasis():
	stasis = false
