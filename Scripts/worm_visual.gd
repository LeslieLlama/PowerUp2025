class_name WormVisual extends Node2D


const OCTAVE_BORDERS: PackedFloat32Array = [
	11,
	22,
	44,
	88,
	177,
	355,
	710,
	1420,
	2840,
	5680,
	11360,
	22720,
]
const OCTAVE_CENTRES: PackedFloat32Array = [
	16,
	31.5,
	63,
	125,
	250,
	500,
	1000,
	2000, 
	4000,
	8000,
	16000,
]
const THETA_FACTOR: float = 1
const OCTAVE_COUNT: int = len(OCTAVE_CENTRES)
const MIN_DB := 60.0
# Drawing Parameters
const COLOUR_ONE := Color(0.776, 0.6, 0.639, 1.0)
const COLOUR_TWO := Color(0.576, 0.353, 0.4, 1.0)
const COLOUR_BORDER := Color(0.4, 0.239, 0.278, 1.0)
@export var colour_alternate_count = 8

@export var point_count := 160
@export var worm_length := 160.0
@export var max_magnitude := 20.0

@export var body_radius := 6.0
@export var border_radius := 3.0

const INCREASE_MAGN_DIST := 0.0

@onready var separation := worm_length / point_count
@onready var max_length := worm_length
@onready var max_points := point_count

var current_magnitudes: PackedFloat32Array = []
var spectrum: AudioEffectSpectrumAnalyzerInstance

var pts: PackedVector2Array = []


func _ready() -> void:
	if get_tree().current_scene == self:
		$TestCamera.enabled = true
		$TestAudio.playing = true
		setup(Vector2.LEFT)
	# WormWiggle Bus, the only SpectrumAnalyzer
	spectrum = AudioServer.get_bus_effect_instance(1,0)
	current_magnitudes.resize(OCTAVE_COUNT)
	current_magnitudes.fill(0.0)


func setup(direction: Vector2):
	pts.resize(point_count)
	for i in point_count:
		pts[i] = direction * separation * i


func get_current_magnitudes():
	var magnitudes: PackedFloat32Array = []
	
	for i in OCTAVE_COUNT:
		# x component is magnitude of sound in left ear, y is magnitude of sound in right ear
		var freq_min: float = OCTAVE_BORDERS[i]
		var freq_max: float = OCTAVE_BORDERS[i + 1]
		var magni: Vector2 = spectrum.get_magnitude_for_frequency_range(
			freq_min,
			freq_max,
			AudioEffectSpectrumAnalyzerInstance.MagnitudeMode.MAGNITUDE_MAX
			)

		magnitudes.append(
			clampf((linear_to_db(magni.length()) + MIN_DB) / MIN_DB, 0.0, 1.0)
			)
	return magnitudes


func sample(magnitudes: PackedFloat32Array, t: float):
	var total: float = 0.0
	for i in OCTAVE_COUNT:
		if is_zero_approx(magnitudes[i]):
			continue
		total += (-1.0 if i % 2 == 0 else 1.0) * magnitudes[i] * sin(TAU / OCTAVE_CENTRES[i] * t * THETA_FACTOR)
	return total


func _process(_delta: float) -> void:
	var target_magnitudes = get_current_magnitudes()
	for i in OCTAVE_COUNT:
		current_magnitudes[i] = lerpf(
			current_magnitudes[i],
			target_magnitudes[i],
			0.2
		)
	queue_redraw()
	
	if get_tree().current_scene != self:
		return
	var vel = position.direction_to(get_local_mouse_position())
	#position += vel
	move_source(vel)
	move_source(Vector2.ZERO)


func _draw() -> void:
	if pts.size() == 0:
		pts.resize(point_count)
		pts.fill(Vector2.ZERO)
	var draw_pts: PackedVector2Array = pts.duplicate()
	for i in point_count:
		var current_dist = worm_length * i / point_count
		var magnitude_mult
		if current_dist >= INCREASE_MAGN_DIST:
			magnitude_mult = 1.0
		else:
			magnitude_mult = current_dist / INCREASE_MAGN_DIST
		
		# Normal by magnitude by sin sum
		draw_pts[i] += get_normal_at_idx(i) * max_magnitude * sample(current_magnitudes, current_dist) * magnitude_mult
	# Border
	for i in point_count:
		draw_circle(draw_pts[i], body_radius + border_radius, COLOUR_BORDER)
	
	# Go backwards for the circles to stack properly
	for i in range(point_count - 1, -1, -1):
		var current_colour: Color
		if i % (2 * colour_alternate_count) < colour_alternate_count:
			current_colour = COLOUR_ONE
		else:
			current_colour = COLOUR_TWO
		
		draw_circle(draw_pts[i], body_radius, current_colour)


func death_anim(time: float):
	var t := get_tree().create_tween()
	t.tween_property(self, "worm_length", 0, time)


func move_source(distance: Vector2):
	for i in range(1, len(pts)):
		pts[i] = (pts[i] - distance).move_toward(
			pts[i - 1],
			(pts[i] - distance).distance_to(pts[i - 1]) - separation
		)


func get_normal_at_idx(idx: int) -> Vector2:
	if idx == 0:
		return pts[1].direction_to(pts[0]).rotated(TAU / 4)
	if idx == len(pts) - 1:
		return pts[-2].direction_to(pts[-1]).rotated(TAU / 4)
	return pts[idx - 1].direction_to(pts[idx + 1]).rotated(TAU / 4)
