extends Node

signal next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType)
signal score_update

func emit_next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType) -> void:
	next_tetromino.emit(tetromino_shape)

func emit_score_update() -> void:
	score_update.emit()
