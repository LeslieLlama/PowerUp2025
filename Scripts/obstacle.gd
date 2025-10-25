class_name Obstacle extends StaticBody2D

## Effect to be applied when worm hits this obstacle
@export var effect: AudioEffect
## Whether or not the worm should bounce off without user input
@export var reflect: bool = true
## How much catchiness is lost or gained when worm hits this material
@export var catchy_change: float = 0.0


func apply_effect():
	AudioServer.add_bus_effect(2, effect)
