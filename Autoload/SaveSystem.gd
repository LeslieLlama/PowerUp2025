extends Node

var level_times = []
var level_number_of_humans = []
var level_number_of_infected_humans = []

func _ready() -> void:
	Signals.game_started.connect(_game_started)
	#level_times = [6.0, 6.0, 6.0]
	load_game()
	print(SaveSystem.level_times)
	
	
func _game_started():
	await get_tree().create_timer(0.01).timeout
	load_game()

func clear_save():
	#reset the level times and # of infected humans to their default 
	level_times = [60,60,60,60,60,60,60]
	level_number_of_infected_humans = [0,0,0,0,0,0,0,0]
	#This figure never changes and is hardcoded based on the number of humans in the level, but needs to be set up when the game is first initialized
	level_number_of_humans = [4,6,6,9,4,4,4,4,4,4]
	save_game()

#don't call this, it's used by the actual save function save_game
func save():
	var save_dict = {
		"levelTimes" : level_times,
		"levelNumberOfHumans" : level_number_of_humans,
		"levelNumberOfInfectedHumans" : level_number_of_infected_humans
	}
	return save_dict
	
#call this whenever you'd like to save the game!
func save_game():
	var save_file = FileAccess.open("user://OBH.save", FileAccess.WRITE)
	
	var json_stirng = JSON.stringify(save())
	
	save_file.store_line(json_stirng)

#Call this whenever you'd like to load the game!
func load_game():
	if not FileAccess.file_exists("user://OBH.save"):
		#create a fresh save file
		clear_save()
	var save_file = FileAccess.open("user://OBH.save", FileAccess.READ)
	var node_data
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		node_data = json.get_data()
		
	#collectibles_gained = node_data["thingsCollected"]
	#current_save_position = Vector2(node_data["current_save_position"][0],node_data["current_save_position"][1])
	#for i in collectibles_gained:
		#if "moon" in i:
			#number_of_moons += 1
		#else:
			#number_of_powerups += 1
	level_times = node_data["levelTimes"]
	level_number_of_humans = node_data["levelNumberOfHumans"]
	level_number_of_infected_humans = node_data["levelNumberOfInfectedHumans"]
	Signals.emit_signal("game_loaded")
	
