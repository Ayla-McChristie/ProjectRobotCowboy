extends Area3D

@onready var particles = $GPUParticles3D

@export var ATTACK_DAMAGE:= 15
@export var KNOCKBACK_FORCE:= 10

func _process(delta: float) -> void:
	if particles.emitting:
		monitoring = true
	else:
		monitoring = false

	if has_overlapping_areas():
		a



func _apply_blast():
	
	pass


func _on_area_entered(area: Area3D) -> void:
	
	var hitbox = area.get_node("HitboxComponent")
	
	if hitbox:
		var attack = Attack.new()
		attack.attack_damage = ATTACK_DAMAGE
		attack.knockback_force = KNOCKBACK_FORCE
		
		hitbox.damage(attack)
