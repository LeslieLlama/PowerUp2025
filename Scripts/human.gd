extends Area2D

enum Sprites {
	Human = 0,
	NPCBlue = 1,
	NPCRed = 2,
	ParkHater = 3,
	Diver = 4,
	WaterHater = 5,
}
@export var sprite_option := Sprites.Human
@export var show_earworm_sprite: bool = true
@export_category("Test exports")
@export var is_earwormed = false
@onready var sprite_holder := $Sprites
var tween
var human_sprite : Sprite2D

func _ready() -> void:
	sprite_holder.get_child(0).hide()
	sprite_holder.get_child(sprite_option).show()
	
	#messy tween animation, can be futzs around with to get a better idle bounce
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_BOUNCE).set_loops()
	tween.tween_property(self, "scale", Vector2(1.05,1.05), 0.5)
	tween.parallel().tween_property(self, "skew", 0.05, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", 1, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)
	tween.parallel().tween_property(self, "skew", -0.05, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", -1, 0.5)
	

func _process(_delta: float) -> void:
	pass
	
func check_worm_state():
	if is_earwormed == true:
		if show_earworm_sprite:
			$Sprites/EarwormSprite.visible = true
			# Animation
		if sprite_option == Sprites.ParkHater:
			$Sprites/ParkHater.hide()
			$Sprites/ParkHaterAngry.show()
	else: 
		$Sprites/EarwormSprite.visible = false
		if sprite_option == Sprites.ParkHater:
			$Sprites/ParkHater.show()
			$Sprites/ParkHaterAngry.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("worm"):
		receive_worm(body)
	
func receive_worm(body: Node2D):
	is_earwormed = true
	check_worm_state()
	body._stop_movement($Earworm_Position.global_position)

	# Reset catchiness
	body.change_catchiness(1.0)
	body.speed = body.DEFAULT_SPEED
	Signals.emit_signal("human_infected", self)
