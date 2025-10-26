extends Button

@export var scene_to_load : PackedScene

func _on_pressed() -> void:
	call_deferred("next_level")
	
func next_level():
	get_tree().change_scene_to_packed(scene_to_load)
