extends CharacterBody2D


@export var level: LevelInfo
@export var cam: Camera2D

@onready var aiming_line : Line2D = $AimingLine
@onready var sprite_2D : Sprite2D = $Sprite2D
@onready var visual: WormVisual = $WormVisual

#buffer to stop the player from immediately clicking to start the level
var lock_movement : bool = true

var first_shot_taken = false
var is_stopped = true
const DEFAULT_SPEED := 400.0
var speed = 450

## Measure of health. 0 to 1.
var catchiness = 1.0
## This variable plays catchup to the one above and is used for display
var catchiness_display: float = 1.0
const CATCHINESS_DECAY := 0.05 # one twentieth; twenty seconds until full decay

var tween
var dir = Vector2(0,0)
var anchor_position : Vector2

func _ready() -> void:
	Signals.player_death.connect(_player_death)

func _process(_delta: float) -> void:
	$VelocityLabel.text = str("v: ",velocity)
		
func _physics_process(delta: float) -> void:
	if lock_movement == true:
		return
	if is_stopped == true:
		velocity = Vector2(0.0,0.0)
	if Input.is_action_just_pressed("fire"):
		anchor_position = get_global_mouse_position()
	if Input.is_action_pressed("fire"):
		if is_stopped == true:
			dir = (get_global_mouse_position() - anchor_position).normalized()
			var canvas_transform = get_global_transform_with_canvas()
			aiming_line.points = [canvas_transform, clamp_vector(get_global_mouse_position() - anchor_position, Vector2(0,0), 140)]
	if Input.is_action_just_released("fire"):
		if first_shot_taken == false:
			Signals.emit_signal("first_shot")
			first_shot_taken = true
		if is_stopped == true:
			velocity = dir.normalized()
			aiming_line.points = [Vector2.ZERO, Vector2.ZERO]
			is_stopped = false
	
	var collision = move_and_collide(velocity * speed * delta)
	visual.move_source(velocity * speed * delta)
	cam.update(global_position + velocity * speed * delta)
	if velocity:
		change_catchiness(-CATCHINESS_DECAY * delta)
	if collision:
		level.obstacles_hit_count += 1
		if collision.get_collider() is BounceObstacle:
			level.bounces_count += 1
			# "bounce" is a handy function that reflects the velocity perfectly
			velocity = velocity.bounce(collision.get_normal())
			collision.get_collider().apply_effect(self)
			
	
#funcion called by a human object, stops movement and tweens the worm to inside the humans head
func _stop_movement(resting_pos : Vector2):
	is_stopped = true
	tween = create_tween().bind_node(self)
	tween.tween_property(self, "global_position", resting_pos, 0.5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(cam, "zoom", Vector2(2, 2), 0.5).set_trans(Tween.TRANS_QUART)
	tween.tween_property(cam, "zoom", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_QUART)

func clamp_vector(vector, clamp_origin, clamp_length):
	var offset = vector - clamp_origin
	var offset_length = offset.length()
	if offset_length <= clamp_length:
		return vector
	return clamp_origin + offset * (clamp_length / offset_length)

func change_catchiness(amnt: float):
	catchiness = clampf(catchiness + amnt, 0.0, 1.0)
	catchiness_display = lerp(catchiness_display, catchiness, 0.2)
	
	visual.worm_length = visual.max_length * catchiness_display
	visual.point_count = int(visual.max_points * catchiness_display)
	
	if catchiness == 0.0:
		# Lose case
		Signals.cactchiness_gone.emit()

func _on_click_buffer_timer_timeout() -> void:
	lock_movement = false
	
func _player_death():
	is_stopped = true
	lock_movement = true
	#some kind of death/explosion visual?
	
