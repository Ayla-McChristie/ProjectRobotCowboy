extends Node3D

const MAXAMMO = 6

#Camera Ray
@export var ray : RayCast3D

@export var aim_angle : float = 10



var cylinder: Array[Global.BulletType]
var can_shoot = true
var reload_timestamp
var reload_cooldown = 100
var can_reload = true

#Bullets"res://scenes/Bullets/bullet.tscn"
var normal_bullet = load("res://scenes/Bullets/bullet.tscn")
var blast_bullet = load("res://scenes/Bullets/Bullet_Blast.tscn")
var instance



#Audio
@export var audio_shoot : AudioStreamPlayer3D
@export var audio_reload : AudioStreamPlayer3D

@onready var gun_anim = $AnimationPlayer
@onready var gun_barrel : RayCast3D = $RayCast3D

func LoadAmmo(bullet : Global.BulletType) -> void:
	if cylinder.size() < 6:
		cylinder.push_back(bullet)
	else:
		print_debug("Cylinder full")

func Fire() -> void:
	if cylinder.size() > 0:
		if can_shoot && !gun_anim.is_playing():
			gun_anim.play("Shoot")
			
			audio_shoot.play()
			
			var bullet = cylinder.pop_front()
			
			if	bullet == Global.BulletType.Normal:
				instance = normal_bullet.instantiate()
				instance.position = gun_barrel.global_position
				instance.transform.basis = gun_barrel.global_transform.basis
				get_tree().root.add_child(instance)
			
			if bullet == Global.BulletType.Blast:
				instance = blast_bullet.instantiate()
				instance.position = gun_barrel.global_position
				instance.transform.basis = gun_barrel.global_transform.basis
				var particles:GPUParticles3D = instance.get_node("GPUParticles3D")
				if	particles:
					particles.emitting = true
				get_tree().root.add_child(instance)
		
func Reload(bullet : Global.BulletType, anim: String) -> void:
	if cylinder.size() < 6:
		if !gun_anim.is_playing() && !Input.is_action_pressed("primary_fire"):
			gun_anim.play(anim)
			
			audio_reload.play()
			
			print_debug("Loading ammo")
			LoadAmmo(bullet)
			print_debug(cylinder.size())
			
			
			reload_timestamp = Time.get_ticks_msec() + reload_cooldown
			can_reload = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_debug(cylinder.size())
	LoadAmmo(Global.BulletType.Normal)
	print_debug(cylinder.size())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !can_reload && reload_timestamp < Time.get_ticks_msec():
		can_reload = true
	if ray.is_colliding():
				gun_barrel.look_at(ray.get_collision_point())
