extends Node3D

@export var ATTACK_DAMAGE: float = 10
@export var KNOCKBACK_FORCE: float = 10

const SPEED = 40.00
@onready var mesh =  $MeshInstance3D
@onready var ray: RayCast3D = $RayCast3D

var collisionSFX = load("res://scenes/SFX/BulletCollisionSFX.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0, -SPEED) * delta
		


func _on_damage_area_body_entered(area : Node3D) -> void:
	var instance = collisionSFX.instantiate()
	if ray.is_colliding():
		instance.position = ray.get_collision_point()
	else: 
		instance.position = global_position
	instance.emitting = true
	get_tree().root.add_child(instance)
	print_debug("bullet collided")
	
	var hitbox = area.get_node("HitboxComponent")
	
	if hitbox:
		var attack = Attack.new()
		attack.attack_damage = ATTACK_DAMAGE
		attack.knockback_force = KNOCKBACK_FORCE
		attack.attack_point = global_position
		hitbox.damage(attack)

	queue_free()
