class_name LevelInfo extends Node2D

var best_time: float = INF
var level_time: float
var timer_running: bool = false
var game_started = false
var bounces_count: int = 0
var obstacles_hit_count: int = 0
@export var humans: Array[Area2D] = []
@export var main_target: Area2D
@export var stream_player: AudioStreamPlayer
@export var level_rect_extents: Node2D
@export var cam: Camera2D
var infected_humans: Array[Area2D] = []

#this is the code for the level to be saved in the save system, level 1 should be 0, level 2 should be 1, so on and so on. 
@export var level_number : int

var level_rect: Rect2

func _ready() -> void:
	Signals.human_infected.connect(_on_new_human_infected)
	Signals.first_shot.connect(start)
	Signals.player_death.connect(_player_death)
	UI_Update()
	level_rect = Rect2()
	for i in level_rect_extents.get_children():
		level_rect = level_rect.expand(i.position)
	cam.fill_level_rect()


func _on_new_human_infected(human: Area2D):
	for i in AudioServer.get_bus_effect_count(2):
		AudioServer.remove_bus_effect(2, i)
	# Prevents adding two refs of same human to infected_humans
	if not human in infected_humans:
		infected_humans.append(human)
	# Win condition
	if human == main_target:
		#Signals.main_target_infected.emit(self)
		Signals.emit_signal("main_target_infected")
		$HUD/WinScreen.visible = true
		if infected_humans.size() == humans.size():
			$HUD/WinScreen/AllHumansInfectedText.visible = true
		finish()
		UI_Update()
		
		#if time is lower than saved time, update save file
		if level_time < SaveSystem.level_times[level_number]:
			SaveSystem.level_times[level_number] = level_time
			SaveSystem.save_game()
			$HUD/WinScreen/BestTimeText.visible = true
	

func _reload_scene():
	pass

func _register_human(human : Area2D):
	humans.append(human)
	print(human)

func start():
	game_started = true
	bounces_count = 0
	obstacles_hit_count = 0
	infected_humans = []
	level_time = 0.0
	timer_running = true
	stream_player.play()

func _process(delta: float) -> void:
	#reset button
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	
	if game_started == false or timer_running == false:
		return
	level_time += delta
	
	UI_Update()

func finish():
	timer_running = false
	stream_player.stop()
	if level_time < best_time:
		best_time = level_time
	return level_time
	
func UI_Update():
	#probably not the best to do this with direct $ assignment because it's coupling but for the interests of time I'm alright leaving it like this for now!
	$HUD/Level_Time_Label.text = str("Time : ",str("%0.2f" % level_time))
	$HUD/Humans_Infected_Label.text = str("Humans : ",infected_humans.size(),"/",humans.size())
	$HUD/Bounces.text = str("bounces : ",bounces_count)
	
func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
	
func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _player_death():
	$HUD/DeathSCreen.visible = true
