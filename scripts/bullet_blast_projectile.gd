extends Node3D

@export var ATTACK_DAMAGE: float = 10
@export var KNOCKBACK_FORCE: float = 10

const SPEED = 40.00
@onready var mesh =  $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D

var expolsion = load("res://scenes/Bullets/Bullet_Blast_Explosion.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0, -SPEED) * delta
		

func _on_damage_area_body_entered(area : Node3D) -> void:
	var instance = expolsion.instantiate()
	instance.position = global_position
	get_tree().root.add_child(instance)
	print_debug("bullet collided")
	
	var hitbox = area.get_node_or_null("HitboxComponent")
	
	if hitbox:
		var attack = Attack.new()
		attack.attack_damage = ATTACK_DAMAGE
		attack.knockback_force = KNOCKBACK_FORCE
		attack.attack_point = global_position
		hitbox.damage(attack)

	queue_free()
