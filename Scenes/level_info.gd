class_name LevelInfo extends CanvasLayer

var best_time: float = INF
var level_time: float
var timer_running: bool = false

var bounces_count: int = 0
var obstacles_hit_count: int = 0
@export var humans: Array[Area2D] = []
@export var main_target: Area2D
var infected_humans: Array[Area2D] = []


func _ready() -> void:
	Signals.human_infected.connect(_on_new_human_infected)

func _on_new_human_infected(human: Area2D):
	# Win condition
	if human == main_target:
		Signals.main_target_infected.emit(self)
		return
	
	# No double counting
	if human in infected_humans:
		return
	
	infected_humans.append(human)
	_update_ui()

func _update_ui():
	$HUD/HumanTrackerLabel.text = str(infected_humans.size(),"/",humans.size())

func _register_human(human : Area2D):
	humans.append(human)
	print(human)
	_update_ui()


func start():
	bounces_count = 0
	obstacles_hit_count = 0
	infected_humans = []
	level_time = 0.0
	timer_running = true


func _process(delta: float) -> void:
	level_time += delta


func finish():
	timer_running = false
	if level_time < best_time:
		best_time = level_time
	return level_time
