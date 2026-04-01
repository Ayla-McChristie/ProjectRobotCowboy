extends Node3D
class_name HealthComponent

@onready var collision_shape_3d: CollisionShape3D = $"../CollisionShape3D"
@export var MAX_HEALTH := 10.0
@export var HIT_SOUND : AudioStreamPlayer3D
@export var IS_PLAYER : bool = false

var health: float

func _ready() -> void:
	health = MAX_HEALTH


func damage(attack: Attack):
	##play sound
	if  HIT_SOUND:
		HIT_SOUND.play()
	
	##deal damage
	if MAX_HEALTH != 0:
		if !(attack.is_player_attack && IS_PLAYER):
			health -= attack.attack_damage
		print_debug(str(self.name) + " took " + str(attack.attack_damage) + " damage")
		if health <= 0:
			get_parent().queue_free()
