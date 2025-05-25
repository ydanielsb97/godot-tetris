extends CPUParticles2D
class_name DestroyFX

func _ready() -> void:
	emitting = true


func _on_finished() -> void:
	queue_free()
