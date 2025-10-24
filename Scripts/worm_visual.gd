extends Node2D


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
const OCTAVE_COUNT: int = 11
const MIN_DB := 60.0
# Drawing Parameters
const COLOUR_ALTERNATE_COUNT := 8
const COLOUR_ONE := Color(0.776, 0.6, 0.639, 1.0)
const COLOUR_TWO := Color(0.576, 0.353, 0.4, 1.0)
const COLOUR_BORDER := Color(0.4, 0.239, 0.278, 1.0)

const POINT_COUNT := 160
const WORM_LENGTH := 160.0
const MAX_MAGNITUDE := 20.0

const WORM_RADIUS := 6.0
const BORDER_RADIUS := 3.0


var current_magnitudes: PackedFloat32Array = []
var spectrum: AudioEffectSpectrumAnalyzerInstance


func _ready() -> void:
	if get_tree().current_scene == self:
		$TestCamera.enabled = true
		$TestAudio.playing = true
	spectrum = AudioServer.get_bus_effect_instance(0,1)
	current_magnitudes.resize(OCTAVE_COUNT)
	current_magnitudes.fill(0.0)


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
		total += magnitudes[i] * sin(TAU / OCTAVE_CENTRES[i] * t)
	return total


func _process(_delta: float) -> void:
	var target_magnitudes = get_current_magnitudes()
	for i in OCTAVE_COUNT:
		current_magnitudes[i] = lerpf(
			current_magnitudes[i],
			target_magnitudes[i],
			0.3
		)
	queue_redraw()


func _draw() -> void:
	var pts: PackedVector2Array = []
	pts.resize(POINT_COUNT)
	for i in POINT_COUNT:
		pts[i] = Vector2(
			-WORM_LENGTH * i / POINT_COUNT,
			MAX_MAGNITUDE * sample(current_magnitudes, WORM_LENGTH * i / POINT_COUNT)
		)
	# Border
	for i in pts:
		draw_circle(i, WORM_RADIUS + BORDER_RADIUS, COLOUR_BORDER)
	
	var remaining := 1
	var current_colour := COLOUR_ONE
	# Go backwards for the circles to stack properly
	for i in range(POINT_COUNT - 1, -1, -1):
		remaining -= 1
		if remaining == 0:
			remaining = COLOUR_ALTERNATE_COUNT
			if current_colour == COLOUR_ONE:
				current_colour = COLOUR_TWO
			else:
				current_colour = COLOUR_ONE
		
		draw_circle(pts[i], WORM_RADIUS, current_colour)
