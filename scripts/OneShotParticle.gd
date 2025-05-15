extends GPUParticles3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.emitting:
		print_debug("Particle Emission Ended")
		queue_free()
