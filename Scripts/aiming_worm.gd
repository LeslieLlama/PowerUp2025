extends CharacterBody2D

@onready var aiming_line : Line2D = $AimingLine
@onready var sprite_2D : Sprite2D = $Sprite2D
@onready var cam : Camera2D = $Camera2D
@onready var visual: WormVisual = $WormVisual

var speed = 300
var dir = Vector2(0,0)
var is_stopped = true
@export var max_collisions := 6
var collision_count = 0

var tween

func _init() -> void:
	pass

func _process(_delta: float) -> void:
	$VelocityLabel.text = str("v: ",velocity)
		
		
func _physics_process(delta: float) -> void:
	if is_stopped == true:
		velocity = Vector2(0.0,0.0)
	if Input.is_action_pressed("fire"):
		dir = (get_global_mouse_position() - global_position).normalized()
		aiming_line.points = [Vector2.ZERO, get_local_mouse_position()]
		is_stopped = false
	if Input.is_action_just_released("fire"):
		velocity = dir.normalized() * speed
		aiming_line.points = [Vector2.ZERO, Vector2.ZERO]
	
	var collision = move_and_collide(velocity * delta)
	visual.move_source(velocity * delta)
	if collision:
		# "bounce" is a handy function that reflects the velocity perfectly
		velocity = velocity.bounce(collision.get_normal())
	
#funcion called by a human object, stops movement and tweens the worm to inside the humans head
func _stop_movement(resting_pos : Vector2):
	is_stopped = true
	tween = create_tween().bind_node(self)
	tween.tween_property(self, "global_position", resting_pos, 0.5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(cam, "zoom", Vector2(2, 2), 0.5).set_trans(Tween.TRANS_QUART)
	tween.tween_property(cam, "zoom", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_QUART)
