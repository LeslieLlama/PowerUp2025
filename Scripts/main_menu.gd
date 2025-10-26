extends Control

func back():
	$HomeScreen.visible = true
	$MapScreen.visible = false
	
func _enter_level_select():
	$HomeScreen.visible = false
	$MapScreen.visible = true
	#SaveSystem.level_times[0]
	
func _ready() -> void:
	_update_UI()
	
func _on_clear_save_button_pressed() -> void:
	SaveSystem.clear_save()
	_update_UI()

func _update_UI():
	#absolutely decroded implementation that isnt reasonably scalable but we're doing like 5 levels max, something to fix up in post
	$MapScreen/Level1Button/ScoreLabel.text = str(
		#str("Time : ",str("%0.2f" % level_time))
		"Time : ",str("%0.2f" % SaveSystem.level_times[0]),
		"\nHumans : 0/4")
	$MapScreen/LevelButton2/ScoreLabel.text = str(
		"Time : ",str("%0.2f" % SaveSystem.level_times[1]),
		"\nHumans : 0/4")
