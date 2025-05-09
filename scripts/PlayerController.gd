extends CharacterBody3D
#
#Movement
#region Movement
var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.10
const VERT_SENSITIVITY = 0.08
const SENSITIVITY_DAMP = 40

const AIR_DRIFT = 3.0
const FRICTION = 7.0

#Coyote time / jump assist
const COYOTE_TIME = 0.4
var coyote_timer = 0.0
var has_jumped = false

#head bob
const  BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

#misc
const FALL_GRAVITY = 12
const JUMP_GRAVITY = 9.8
#endregion

#References
#region References
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var gun = $Head/Camera3D/Gun

#endregion

func  _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
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
#region Gravity
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
		if velocity.y > 0 and Input.is_action_pressed("jump"):
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
#endregion
#region Jump
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and coyote_timer < COYOTE_TIME and has_jumped == false:
		velocity.y = JUMP_VELOCITY
		has_jumped = true
#endregion
	
#region Sprint
	# Handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
#endregion

#region Walking
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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
#endregion
	
#region Head Bob
	#head bob
	if is_on_floor():
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = _headbob(t_bob)
		
#endregion
#region Fov
	#fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	#camera.fov = lerp(camera.fov, target_fov, delta *8.0)
#endregion
	
#region Gun
	#shooting 
	if Input.is_action_pressed("primary_fire"):
		#TODO reference gun_controller Fire
		gun.Fire()
		pass
	
	if Input.is_action_pressed("reload"):
		gun.Reload(Global.BulletType.Normal)
#endregion

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	return pos
