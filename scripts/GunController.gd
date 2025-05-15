extends Node

const MAXAMMO = 6



var cylinder: Array[Global.BulletType]
var can_shoot = true
var reload_timestamp
var reload_cooldown = 100
var can_reload = true

#Bullets
var normal_bullet = load("res://scenes/bullet.tscn")
var instance

@onready var gun_anim = $AnimationPlayer
@onready var gun_barrel = $RayCast3D

func LoadAmmo(bullet : Global.BulletType) -> void:
	if cylinder.size() < 6:
		cylinder.push_back(bullet)
	else:
		print_debug("Cylinder full")

func Fire() -> void:
	if cylinder.size() > 0:
		if can_shoot && !gun_anim.is_playing():
			gun_anim.play("Shoot")
			instance = normal_bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_tree().root.add_child(instance)
			return cylinder.pop_front()
		
func Reload(bullet : Global.BulletType) -> void:
	if cylinder.size() < 6:
		if can_reload && !gun_anim.is_playing() && !Input.is_action_pressed("primary_fire"):
			gun_anim.play("Reload")
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
