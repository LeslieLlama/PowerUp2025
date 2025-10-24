extends Area2D

@export var is_earwormed = false
var tween
var human_sprite : Sprite2D

func _init() -> void:
	tween = create_tween().bind_node(self).set_trans(Tween.TRANS_BOUNCE).set_loops()
	tween.tween_property(self, "scale", Vector2(1.05,1.05), 0.5)
	tween.parallel().tween_property(self, "skew", 0.05, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", 1, 0.5)
	tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.5)
	tween.parallel().tween_property(self, "skew", -0.05, 0.5)
	tween.parallel().tween_property(self, "rotation_degrees", -1, 0.5)

func _process(delta: float) -> void:
	if is_earwormed == true:
		$EarwormSprite.visible = true
	else: 
		$EarwormSprite.visible = false
