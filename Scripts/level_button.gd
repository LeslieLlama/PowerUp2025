extends Button

@export var path_to_scene_to_load : String

func _on_pressed() -> void:
	call_deferred("next_level")
	
func next_level():
	get_tree().change_scene_to_file(path_to_scene_to_load)
