extends Control

func back():
	$HomeScreen.visible = true
	$MapScreen.visible = false
	
func _enter_level_select():
	$HomeScreen.visible = false
	$MapScreen.visible = true
	#SaveSystem.level_times[0]
	
func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	_update_UI()
	
func _on_clear_save_button_pressed() -> void:
	SaveSystem.clear_save()
	_update_UI()

func _update_UI():
	$MapScreen/Level1Button/TimeStar.visible = false
	$MapScreen/Level1Button/HumanStar.visible = false
	$MapScreen/LevelButton2/TimeStar.visible = false
	$MapScreen/LevelButton2/HumanStar.visible = false
	$MapScreen/LevelButton3/TimeStar.visible = false
	$MapScreen/LevelButton3/HumanStar.visible = false
	$MapScreen/LevelButton4/TimeStar.visible = false
	$MapScreen/LevelButton4/HumanStar.visible = false
	$"MapScreen/100_marker".visible = false
	#print(SaveSystem.level_number_of_infected_humans[1])
	#absolutely decroded implementation that isnt reasonably scalable but we're doing like 5 levels max, something to fix up in post
	$MapScreen/Level1Button/ScoreLabel.text = str(
		#str("Time : ",str("%0.2f" % level_time))
		"Time : ",str("%0.2f" % SaveSystem.level_times[0]),
		"\n",
		"Humans : ",int(SaveSystem.level_number_of_infected_humans[0]),"/",int(SaveSystem.level_number_of_humans[0]))
	$MapScreen/LevelButton2/ScoreLabel.text = str(
		"Time : ",str("%0.2f" % SaveSystem.level_times[1]),
		"\n",
		"Humans : ",int(SaveSystem.level_number_of_infected_humans[1]),"/",int(SaveSystem.level_number_of_humans[1]))
	$MapScreen/LevelButton3/ScoreLabel.text = str(
		"Time : ",str("%0.2f" % SaveSystem.level_times[2]),
		"\n",
		"Humans : ",int(SaveSystem.level_number_of_infected_humans[2]),"/",int(SaveSystem.level_number_of_humans[2]))
	$MapScreen/LevelButton4/ScoreLabel.text = str(
		"Time : ",str("%0.2f" % SaveSystem.level_times[3]),
		"\n",
		"Humans : ",int(SaveSystem.level_number_of_infected_humans[3]),"/",int(SaveSystem.level_number_of_humans[3]))

#Lock level if previous levels time hasnt been set
	if SaveSystem.level_times[0] == 60:
		$MapScreen/LevelButton2.disabled = true
	if SaveSystem.level_times[1] == 60:
		$MapScreen/LevelButton3.disabled = true
	if SaveSystem.level_times[2] == 60:
		$MapScreen/LevelButton4.disabled = true
		
#award stars if save file meets level requirements
#feel free to adjust the speedrunning times 
	if SaveSystem.level_times[0] < 5.5:
		$MapScreen/Level1Button/TimeStar.visible = true
	if SaveSystem.level_number_of_infected_humans[0] == SaveSystem.level_number_of_humans[0]:
		$MapScreen/Level1Button/HumanStar.visible = true
		
	if SaveSystem.level_times[1] < 7.0:
		$MapScreen/LevelButton2/TimeStar.visible = true
	if SaveSystem.level_number_of_infected_humans[1] == SaveSystem.level_number_of_humans[1]:
		$MapScreen/LevelButton2/HumanStar.visible = true
		
	if SaveSystem.level_times[2] < 6.0:
		$MapScreen/LevelButton3/TimeStar.visible = true
	if SaveSystem.level_number_of_infected_humans[2] == SaveSystem.level_number_of_humans[2]:
		$MapScreen/LevelButton3/HumanStar.visible = true
	
	if SaveSystem.level_times[3] < 7.0:
		$MapScreen/LevelButton4/TimeStar.visible = true
	if SaveSystem.level_number_of_infected_humans[3] == SaveSystem.level_number_of_humans[3]:
		$MapScreen/LevelButton4/HumanStar.visible = true
		
	#reverse if statement check. if all of the stars are visible then show the 100% marker, otherwise exit the function early
	if $MapScreen/Level1Button/TimeStar.visible == false:
		return
	if $MapScreen/Level1Button/HumanStar.visible == false:
		return
	if $MapScreen/LevelButton2/TimeStar.visible == false:
		return
	if $MapScreen/LevelButton2/HumanStar.visible == false:
		return
	if $MapScreen/LevelButton3/TimeStar.visible == false:
		return
	if $MapScreen/LevelButton3/HumanStar.visible == false:
		return
	if $MapScreen/LevelButton4/TimeStar.visible == false:
		return
	if $MapScreen/LevelButton4/HumanStar.visible == false:
		return
	$"MapScreen/100_marker".visible = true
	
