extends Area3D

@export var ATTACK_DAMAGE: float = 10
@export var KNOCKBACK_FORCE: float = 10

@onready var explosion_sound: AudioStreamPlayer3D = $Explosion_Sound
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explosion_sound.play()
	gpu_particles_3d.restart()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !explosion_sound.playing && !gpu_particles_3d.emitting:
		queue_free()

func _on_area_entered(area: Area3D) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if gpu_particles_3d.emitting:
		var hitbox = body.get_node_or_null("HitboxComponent")
		
		if hitbox:
			var attack = Attack.new()
			
			print_debug(body.get_collision_layer())
			
			if body.get_collision_layer() == 3:
				attack.attack_damage = 0.0
				attack.knockback_force = KNOCKBACK_FORCE
			else:
				attack.attack_damage = ATTACK_DAMAGE
				attack.knockback_force = KNOCKBACK_FORCE
			
			attack.attack_point = global_position
			hitbox.damage(attack)
