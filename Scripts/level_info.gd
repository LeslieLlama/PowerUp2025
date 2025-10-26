class_name LevelInfo extends Node2D

var best_time: float = INF
var level_time: float
var timer_running: bool = false
var game_started = false
var bounces_count: int = 0
var obstacles_hit_count: int = 0
@export var humans: Array[Area2D] = []
@export var main_target: Area2D
var infected_humans: Array[Area2D] = []


func _ready() -> void:
	Signals.human_infected.connect(_on_new_human_infected)
	Signals.first_shot.connect(start)

	
func _on_new_human_infected(human: Area2D):
	infected_humans.append(human)
	# Win condition
	if human == main_target:
		#Signals.main_target_infected.emit(self)
		Signals.emit_signal("main_target_infected")
		$HUD/WinText.visible = true
		finish()
		UI_Update()
	# No double counting
	#if human in infected_humans:
		#return
	

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

func _process(delta: float) -> void:
	if game_started == false or timer_running == false:
		return
	level_time += delta
	
	UI_Update()

func finish():
	timer_running = false
	if level_time < best_time:
		best_time = level_time
	return level_time
	
func UI_Update():
	#probably not the best to do this with direct $ assignment because it's coupling but for the interests of time I'm alright leaving it like this for now!
	$HUD/Level_Time_Label.text = str("Time : ",str("%0.2f" % level_time))
	$HUD/Humans_Infected_Label.text = str("Humans : ",infected_humans.size(),"/",humans.size())
	$HUD/Bounces.text = str("bounces : ",bounces_count)
