extends Area2D



func _on_body_entered(body: Node2D) -> void:
	Signals.emit_signal("player_death")
	print("ougb")
