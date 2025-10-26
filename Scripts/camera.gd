extends Camera2D

var scout_mode:bool = true
@export var follow_target: Node2D
@export var zoom_target: float
@export var zoom_scout: float
@onready var level: LevelInfo = $".."


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		switch_to_follow()


func update(approach: Vector2) -> void:
	if scout_mode:
		return
	global_position = lerp(global_position, approach, 1.0)
	var centre_rect: Rect2 = level.level_rect.grow_individual(
		-get_viewport_rect().size.x / zoom.x / 2,
		-get_viewport_rect().size.y / zoom.y / 2,
		-get_viewport_rect().size.x / zoom.x / 2,
		-get_viewport_rect().size.y / zoom.y / 2,
	)
	global_position = global_position.clamp(centre_rect.position, centre_rect.end)
	pass


func switch_to_follow():
	var t := create_tween().bind_node(self)
	t.tween_property(self, "zoom", Vector2.ONE * zoom_target, 0.3)
	scout_mode = false


func fill_level_rect():
	global_position = level.level_rect.get_center()
	
	# Take the higher zoom out of vertical and horizontal
	zoom = Vector2.ONE * max(
		get_viewport_rect().size.x / level.level_rect.size.x,
		get_viewport_rect().size.y / level.level_rect.size.y
	)
