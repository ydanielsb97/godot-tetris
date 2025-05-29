extends Node

enum SFX {
	HARD_DROP,
	GAME_OVER,
	DOUBLE,
	HARD_DROP_ALT,
	LANDING,
	SINGLE,
	TETRIS,
	TRIPLE,
	MUSIC,
	ROTATE,
	SOFT_DROP,
	LEVEL_UP
}

var sfx_files := {
	SFX.HARD_DROP: preload("res://assets/audios/hard_drop.wav"),
	SFX.GAME_OVER: preload("res://assets/audios/me_game_gameover.wav"),
	SFX.DOUBLE: preload("res://assets/audios/se_game_double.wav"),
	SFX.LEVEL_UP: preload("res://assets/audios/me_game_plvup.wav"),
	SFX.HARD_DROP_ALT: preload("res://assets/audios/se_game_harddrop.wav"),
	SFX.LANDING: preload("res://assets/audios/se_game_landing.wav"),
	SFX.SINGLE: preload("res://assets/audios/se_game_single.wav"),
	SFX.TETRIS: preload("res://assets/audios/se_game_tetris.wav"),
	SFX.TRIPLE: preload("res://assets/audios/se_game_triple.wav"),
	SFX.ROTATE: preload("res://assets/audios/se_game_rotate.wav"),
	SFX.SOFT_DROP: preload("res://assets/audios/se_game_softdrop.wav")
}

var sounds_playing: Array[SFX] = []

func play_sfx(sfx_type: SFX):
	var audio = AudioStreamPlayer.new()
	sfx_files[sfx_type]
	audio.stream = sfx_files[sfx_type]
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	audio.connect("finished", func () -> void: 
		audio.queue_free()
	)
