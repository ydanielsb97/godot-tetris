extends Node

signal next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType)
signal score_update
signal game_start
signal game_paused(paused)
signal game_over
signal has_landed
signal ready_to_add_block

func emit_next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType) -> void:
	next_tetromino.emit(tetromino_shape)

func emit_score_update() -> void:
	score_update.emit()

func emit_game_start() -> void:
	game_start.emit()

func emit_game_over() -> void:
	game_over.emit()

func emit_game_paused(paused: bool) -> void:
	game_paused.emit(paused)

func emit_has_landed() -> void:
	has_landed.emit()

func emit_ready_to_add_block() -> void:
	ready_to_add_block.emit()
