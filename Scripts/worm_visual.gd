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
const POINT_COUNT := 80
const LENGTH := 160.0
const MAX_MAGNITUDE := 10.0


var current_magnitudes: PackedFloat32Array = []
var spectrum: AudioEffectSpectrumAnalyzerInstance


func _ready() -> void:
	if get_tree().current_scene == self:
		$TestCamera.enabled = true
		$TestAudio.playing = true
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	current_magnitudes.resize(OCTAVE_COUNT)
	current_magnitudes.fill(0.0)


func get_current_magnitudes():
	var magnitudes : PackedFloat32Array = []
	
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
		total += magnitudes[i] * sin(TAU * t / OCTAVE_CENTRES[i])
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
			-LENGTH * i / POINT_COUNT,
			MAX_MAGNITUDE * sample(current_magnitudes, LENGTH * i / POINT_COUNT)
		)
	# Just a basic polyline for now
	draw_polyline(
		pts,
		Color.WHITE,
		5.0
	)
