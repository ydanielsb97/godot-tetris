extends Object
class_name TetrominoHelper

enum TetrominoType {
	I,
	O,
	T,
	L,
	J,
	S,
	Z
}

const TETROMINO_SHAPES := {
	TetrominoType.I: {
		"texture": preload("res://assets/images/Tetromino_block2_1.png"),
		"coords": [
			[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],
			[Vector2i(2, 1), Vector2i(2, 0), Vector2i(2, 2), Vector2i(2, 3)]
		]
	},
	TetrominoType.O: {
		"texture": preload("res://assets/images/Tetromino_block2_6.png"),
		"coords": [
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)]
		]
	},
	TetrominoType.T: {
		"texture": preload("res://assets/images/Tetromino_block2_3.png"),
		"coords": [
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(2, 2)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 1), Vector2i(2, 2)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 1), Vector2i(1, 1)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(1, 1)],
		]
	},
	TetrominoType.L: {
		"texture": preload("res://assets/images/Tetromino_block2_7.png"),
		"coords": [
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(1, 2)],
			[Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0), Vector2i(3, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(3, 0)],
			[Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0), Vector2i(1, 0)],
		]
	},
	TetrominoType.J: {
		"texture": preload("res://assets/images/Tetromino_block2_2.png"),
		"coords": [
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(3, 2)],
			[Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0), Vector2i(1, 2)],
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(1, 0)],
			[Vector2i(2, 2), Vector2i(2, 1), Vector2i(2, 0), Vector2i(3, 0)],
		]
	},
	TetrominoType.S: {
		"texture": preload("res://assets/images/Tetromino_block2_5.png"),
		"coords": [
			[Vector2i(2, 1), Vector2i(3, 1), Vector2i(1, 2), Vector2i(2, 2)],
			[Vector2i(3, 2), Vector2i(2, 1), Vector2i(3, 1), Vector2i(2, 0)],
		]
	},
	TetrominoType.Z: {
		"texture": preload("res://assets/images/Tetromino_block2_4.png"),
		"coords": [
			[Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2), Vector2i(3, 2)],
			[Vector2i(2, 0), Vector2i(2, 1), Vector2i(1, 1), Vector2i(1, 2)]
		]
	}
}

const GRID_SIZE_Y: int = 4
const GRID_SIZE_X: int = 4

const SPEEDS: Dictionary[int, float] = {
	0: 0.8,
	1: 0.7167,
	2: 0.6333,
	3: 0.55,
	4: 0.4667,
	5: 0.3833,
	6: 0.3,
	7: 0.2167,
	8: 0.1333,
	9: 0.1,
	10: 0.0833,
	11: 0.0833,
	12: 0.0833,
	13: 0.0667,
	14: 0.0667,
	15: 0.0667,
	16: 0.05,
	17: 0.05,
	18: 0.05,
	19: 0.0333,
	20: 0.0167,
	21: 0.0167,
	22: 0.0167,
	23: 0.0167,
	24: 0.0167,
	25: 0.0167,
	26: 0.0167,
	27: 0.0167,
	28: 0.0167,
	29: 0.0167
}

static func get_random_tetromino_shape() -> TetrominoType:
	return TetrominoType.values().pick_random()

static func get_level_speed() -> float:
	return SPEEDS[ScoreManager.current_score.level]
