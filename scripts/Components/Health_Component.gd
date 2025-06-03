extends Node3D
class_name HealthComponent


@export var MAX_HEALTH := 10.0
@export var HIT_SOUND : AudioStreamPlayer3D


var health: float

func _ready() -> void:
	health = MAX_HEALTH


func damage(attack: Attack):
	HIT_SOUND.play()
	
	if MAX_HEALTH != 0:
		health -= attack.attack_damage
		print_debug("took " + str(attack.attack_damage) + " damage")
		if health <= 0:
			get_parent().queue_free()
