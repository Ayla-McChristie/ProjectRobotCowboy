extends Node3D

const SPEED = 40.00
@onready var mesh =  $MeshInstance3D
@onready var ray = $RayCast3D

var collisionSFX = load("res://scenes/SFX/BulletCollisionSFX.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0, -SPEED) * delta
	if	ray.is_colliding():
		var instance = collisionSFX.instantiate()
		instance.position = ray.get_collision_point()
		instance.emitting = true
		get_tree().root.add_child(instance)
		queue_free()
		print_debug("bullet collided")
