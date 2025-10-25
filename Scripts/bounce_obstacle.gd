class_name BounceObstacle extends StaticBody2D

## Effect to be applied when worm hits this obstacle
@export var effect: AudioEffect
## How much catchiness is lost or gained when worm hits this material
@export var catchy_change: float = -0.2
@export var speed_change: float = 100.0


func apply_effect(b: CharacterBody2D):
	b.speed += speed_change
	b.change_catchiness(catchy_change)
	if effect:
		AudioServer.add_bus_effect(2, effect)
