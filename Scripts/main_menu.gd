extends Control

func load_level(scenepath : String):
	get_tree().change_scene_to(load(scenepath))
