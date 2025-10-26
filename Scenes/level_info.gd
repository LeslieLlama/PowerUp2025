extends CanvasLayer

var level_time
@export var humans: Array[Area2D] = []
var infected_humans: Array[Area2D] = []

func _ready() -> void:
	Signals.human_infected.connect(_update_ui)
	
func _update_ui():
	$HUD/HumanTrackerLabel.text = str(infected_humans.size(),"/",humans.size())

func _register_human(human : Area2D):
	humans.append(human)
	print(human)
	_update_ui()
	
