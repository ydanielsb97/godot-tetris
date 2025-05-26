extends Node

signal next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType)

func emit_next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType) -> void:
	next_tetromino.emit(tetromino_shape)
