extends Area2D

@export var is_earwormed = false
var tween
var human_sprite : Sprite2D

func _ready() -> void:
	#messy tween animation, can be futzs around with to get a better idle bounce
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_BOUNCE).set_loops()
	tween.tween_property(self, "scale", Vector2(1.05,1.05), 0.5)
	tween.parallel().tween_property(self, "skew", 0.05, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", 1, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)
	tween.parallel().tween_property(self, "skew", -0.05, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", -1, 0.5)
	
	await get_tree().create_timer(0.01).timeout

	Signals.emit_signal("register_human", self)

	Signals.emit_signal("register_human", self)

func _process(_delta: float) -> void:
	pass
	
func check_worm_state():
	if is_earwormed == true:
		$EarwormSprite.visible = true
	else: 
		$EarwormSprite.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("worm"):
		receive_worm(body)
		print("collission")
	
func receive_worm(body: Node2D):
	is_earwormed = true
	check_worm_state()
	body._stop_movement($Earworm_Position.global_position)

	# Reset catchiness
	body.change_catchiness(1.0)
	body.speed = 300
	Signals.emit_signal("human_infected", self)

	Signals.emit_signal("human_infected")

	Signals.emit_signal("human_infected")
	
	
