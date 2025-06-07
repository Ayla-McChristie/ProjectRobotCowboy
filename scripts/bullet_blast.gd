extends Area3D

@onready var particles = $GPUParticles3D

@export var ATTACK_DAMAGE:= 15
@export var KNOCKBACK_FORCE:= 10

var has_activated := false

func _process(delta: float) -> void:
	if particles.emitting:
		monitoring = true
		if !has_activated:
			has_activated = true
	else:
		monitoring = false
	
	if has_activated and !particles.emitting:
		queue_free()

func _on_body_entered(area: Node3D) -> void:
	var hitbox = area.get_node("HitboxComponent")
	
	if hitbox:
		var attack = Attack.new()
		attack.attack_damage = ATTACK_DAMAGE
		attack.knockback_force = KNOCKBACK_FORCE
		
		hitbox.damage(attack)
