extends Camera2D

func update(approach: Vector2) -> void:
	global_position = lerp(global_position, approach, 0.1)
	pass
