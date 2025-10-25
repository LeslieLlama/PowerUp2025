extends CharacterBody2D


@export var level: LevelInfo

@onready var aiming_line : Line2D = $AimingLine
@onready var sprite_2D : Sprite2D = $Sprite2D
@onready var cam : Camera2D = $Camera2D
@onready var visual: WormVisual = $WormVisual

var speed = 300
var dir = Vector2(0,0)
var is_stopped = true

## Measure of health. 0 to 1.
var catchiness = 1.0
## This variable plays catchup to the one above and is used for display
var catchiness_display: float = 1.0
const CATCHINESS_DECAY := 0.05 # one twentieth; twenty seconds until full decay

var tween

func _init() -> void:
	assert(level != null, "Set the AimingWorm's 'level' property")
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
		velocity = dir.normalized()
		aiming_line.points = [Vector2.ZERO, Vector2.ZERO]
	
	var collision = move_and_collide(velocity * speed * delta)
	visual.move_source(velocity * speed * delta)
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


func change_catchiness(amnt: float):
	catchiness = clampf(catchiness + amnt, 0.0, 1.0)
	catchiness_display = lerp(catchiness_display, catchiness, 0.2)
	
	visual.worm_length = visual.max_length * catchiness_display
	visual.point_count = int(visual.max_points * catchiness_display)
	
	if catchiness == 0.0:
		# Lose case
		Signals.cactchiness_gone.emit()
