extends CharacterBody2D

@onready var aiming_line : Line2D = $AimingLine
var speed = 150
var dir = Vector2(0,0)
var is_stopped = true
func _init() -> void:
	pass

var mouse_left_down: bool = false
func _input( event ):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false

func _process(_delta: float) -> void:
	if mouse_left_down == true:
		dir = (get_global_mouse_position() - global_position).normalized()
		aiming_line.points = [Vector2.ZERO, get_local_mouse_position()]
		is_stopped = false
	if mouse_left_down == false and is_stopped == false:
		velocity = dir * speed
		aiming_line.points = [Vector2.ZERO, Vector2.ZERO]
	else:
		velocity = Vector2(0.0,0.0)
	move_and_slide()
	
func _stop_movement():
	is_stopped = true
	print("a")
