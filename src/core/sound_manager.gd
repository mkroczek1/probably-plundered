class_name SoundManagerClass
extends Node

var audio_player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.5
	audio_player.stream = generator
	add_child(audio_player)
	audio_player.play()
	playback = audio_player.get_stream_playback()

	if EventBus:
		EventBus.sound_requested.connect(play_sfx)

func play_sfx(sfx_name: String) -> void:
	if not playback:
		return
	match sfx_name:
		"coin":
			_play_coin()
		"fork_chime":
			_play_harmonic_chime()
		"fork_buzz":
			_play_sour_buzz()
		"smoke_clean":
			_play_smoke_fizz(800.0, 0.25)
		"smoke_curse":
			_play_curse_boil()
		"scale_clunk":
			_play_scale_click()
		"monocle":
			_play_monocle_chirp()
		"anvil_strike":
			_play_anvil()
		"vat_bubble":
			_play_bubble()
		"knock":
			_play_knock()
		"warning":
			_play_alarm()
		"haggle_tick":
			_play_click()
		"victory":
			_play_fanfare()
		"game_over":
			_play_doom()
		_:
			_play_click()

func _play_tone(frequency: float, duration: float, decay: float = 4.0, wave_type: String = "sine") -> void:
	var total_frames = int(sample_rate * duration)
	for i in range(total_frames):
		if playback.get_frames_available() <= 0:
			break
		var t = float(i) / sample_rate
		var env = exp(-decay * t)
		var val = 0.0
		if wave_type == "sine":
			val = sin(TAU * frequency * t) * env
		elif wave_type == "square":
			val = (1.0 if sin(TAU * frequency * t) > 0.0 else -1.0) * env * 0.4
		elif wave_type == "saw":
			val = (2.0 * fmod(frequency * t, 1.0) - 1.0) * env * 0.35
		elif wave_type == "noise":
			val = randf_range(-1.0, 1.0) * env * 0.3
		playback.push_frame(Vector2(val * 0.3, val * 0.3))

func _play_coin() -> void:
	_play_tone(1800.0, 0.08, 12.0, "sine")
	_play_tone(2400.0, 0.12, 10.0, "sine")

func _play_harmonic_chime() -> void:
	# Beautiful bell-like pure chord
	var total_frames = int(sample_rate * 0.6)
	for i in range(total_frames):
		if playback.get_frames_available() <= 0:
			break
		var t = float(i) / sample_rate
		var env = exp(-3.0 * t)
		var s1 = sin(TAU * 523.25 * t) # C5
		var s2 = sin(TAU * 659.25 * t) # E5
		var s3 = sin(TAU * 783.99 * t) # G5
		var s4 = sin(TAU * 1046.50 * t) # C6
		var val = (s1 + s2 + s3 + s4) * 0.15 * env
		playback.push_frame(Vector2(val, val))

func _play_sour_buzz() -> void:
	# Dissonant tritone buzzer
	var total_frames = int(sample_rate * 0.4)
	for i in range(total_frames):
		if playback.get_frames_available() <= 0:
			break
		var t = float(i) / sample_rate
		var env = exp(-4.0 * t)
		var s1 = 1.0 if sin(TAU * 140.0 * t) > 0.0 else -1.0
		var s2 = 1.0 if sin(TAU * 198.0 * t) > 0.0 else -1.0
		var val = (s1 + s2) * 0.2 * env
		playback.push_frame(Vector2(val, val))

func _play_smoke_fizz(freq: float, duration: float) -> void:
	var total_frames = int(sample_rate * duration)
	for i in range(total_frames):
		if playback.get_frames_available() <= 0:
			break
		var t = float(i) / sample_rate
		var env = exp(-3.0 * t)
		var val = randf_range(-0.3, 0.3) * env
		playback.push_frame(Vector2(val, val))

func _play_curse_boil() -> void:
	var total_frames = int(sample_rate * 0.5)
	for i in range(total_frames):
		if playback.get_frames_available() <= 0:
			break
		var t = float(i) / sample_rate
		var env = exp(-2.0 * t)
		var wobble = sin(TAU * 15.0 * t) * 60.0
		var val = sin(TAU * (110.0 + wobble) * t) * 0.25 * env
		val += randf_range(-0.15, 0.15) * env
		playback.push_frame(Vector2(val, val))

func _play_scale_click() -> void:
	_play_tone(350.0, 0.06, 18.0, "saw")
	_play_tone(420.0, 0.08, 14.0, "sine")

func _play_monocle_chirp() -> void:
	_play_tone(1200.0, 0.04, 25.0, "sine")
	_play_tone(1600.0, 0.05, 20.0, "sine")

func _play_anvil() -> void:
	_play_tone(880.0, 0.15, 8.0, "saw")
	_play_tone(1760.0, 0.25, 10.0, "sine")

func _play_bubble() -> void:
	_play_tone(300.0, 0.05, 20.0, "sine")
	_play_tone(550.0, 0.07, 18.0, "sine")

func _play_knock() -> void:
	_play_tone(120.0, 0.08, 15.0, "square")
	_play_tone(95.0, 0.10, 12.0, "square")

func _play_alarm() -> void:
	_play_tone(600.0, 0.12, 5.0, "saw")
	_play_tone(750.0, 0.12, 5.0, "saw")

func _play_click() -> void:
	_play_tone(800.0, 0.02, 40.0, "sine")

func _play_fanfare() -> void:
	_play_tone(523.25, 0.15, 4.0, "sine")
	_play_tone(659.25, 0.15, 4.0, "sine")
	_play_tone(783.99, 0.15, 4.0, "sine")
	_play_tone(1046.50, 0.35, 2.5, "sine")

func _play_doom() -> void:
	_play_tone(220.0, 0.3, 2.0, "saw")
	_play_tone(207.65, 0.3, 2.0, "saw")
	_play_tone(196.0, 0.5, 1.5, "saw")
