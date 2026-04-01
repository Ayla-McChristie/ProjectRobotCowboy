extends Area3D

@export var ATTACK_DAMAGE: float = 10
@export var KNOCKBACK_FORCE: float = 10
@export var PHYSICS_OBJECT_MODIFIER: float = 1

@onready var bullet_blast_explosion: Area3D = $"."

@onready var explosion_sound: AudioStreamPlayer3D = $Explosion_Sound
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explosion_sound.play()
	gpu_particles_3d.restart()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	push_away_objects()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !explosion_sound.playing && !gpu_particles_3d.emitting:
		queue_free()

func push_away_objects() -> void:
	for body in bullet_blast_explosion.get_overlapping_bodies():
		var body_pos = body.global_position
		
		var direction =  global_position.direction_to(body.global_position).normalized()
		var force = direction * KNOCKBACK_FORCE
		
		if body is RigidBody3D:
			body.apply_impulse(force * PHYSICS_OBJECT_MODIFIER)

		elif body is CharacterBody3D:
			body.velocity += force

		var hitbox = body.get_node_or_null("HitboxComponent")
		
		if hitbox:
			var attack = Attack.new()
			
			print_debug(body.get_collision_layer())
			
			attack.attack_damage = ATTACK_DAMAGE
			attack.knockback_force = KNOCKBACK_FORCE
			
			attack.is_player_attack = true
			attack.attack_point = global_position
			hitbox.damage(attack)
