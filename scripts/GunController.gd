extends Node

const MAXAMMO = 6

enum BulletType {
	Normal,
	Richochet,
	Recoil,
	Power,
	Oil,
	Spark
}

var cylinder: Array[BulletType]
var can_shoot = true

#Bullets
var bullet = load("res://scenes/bullet.tscn")
var instance

@onready var gun_anim = $AnimationPlayer
@onready var gun_barrel = $RayCast3D

func LoadAmmo(bullet) -> void:
	if cylinder.size() < 6:
		cylinder.push_back(bullet)
	else:
		print_debug("Cylinder full")

func Fire() -> void:
	if cylinder.size() > 0:
		if can_shoot && !gun_anim.is_playing():
			gun_anim.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().get_parent().add_child(instance)
		return cylinder.pop_front()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_debug(cylinder.size())
	LoadAmmo(BulletType.Normal)
	print_debug(cylinder.size())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
