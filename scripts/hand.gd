extends Node3D

#Camera Ray
@export var ray : RayCast3D
# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if ray.is_colliding():
		look_at(ray.get_collision_point())
		
