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
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)],
			[Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, 2), Vector2i(1, 3)]
		]
	},
	TetrominoType.O: {
		"texture": preload("res://assets/images/Tetromino_block2_6.png"),
		"coords": [
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
		]
	},
	TetrominoType.T: {
		"texture": preload("res://assets/images/Tetromino_block2_3.png"),
		"coords": [
			[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],
			[Vector2i(1, 2), Vector2i(2, 1), Vector2i(1, 1), Vector2i(0, 1)],
			[Vector2i(0, 1), Vector2i(1, 2), Vector2i(1, 1), Vector2i(1, 0)]
		]
	},
	TetrominoType.L: {
		"texture": preload("res://assets/images/Tetromino_block2_7.png"),
		"coords": [
			[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(0, 0), Vector2i(1, 2), Vector2i(1, 1), Vector2i(1, 0)],
			[Vector2i(0, 2), Vector2i(2, 1), Vector2i(1, 1), Vector2i(0, 1)],
			[Vector2i(2, 2), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
		]
	},
	TetrominoType.J: {
		"texture": preload("res://assets/images/Tetromino_block2_2.png"),
		"coords": [
			[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 2), Vector2i(1, 1), Vector2i(0, 2)],
			[Vector2i(2, 2), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 2), Vector2i(1, 1), Vector2i(2, 0)]
		]
	},
	TetrominoType.S: {
		"texture": preload("res://assets/images/Tetromino_block2_5.png"),
		"coords": [
			[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],
			[Vector2i(1, 1), Vector2i(1, 0), Vector2i(2, 1), Vector2i(2, 2)]
		]
	},
	TetrominoType.Z: {
		"texture": preload("res://assets/images/Tetromino_block2_4.png"),
		"coords": [
			[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
			[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1), Vector2i(0, 2)]
		]
	}
}

const TETROMINO_WEIGHTS := {
	TetrominoType.I: 3,
	TetrominoType.O: 2,
	TetrominoType.T: 3,
	TetrominoType.L: 2,
	TetrominoType.J: 2,
	TetrominoType.S: 1,
	TetrominoType.Z: 1
}

const GRID_SIZE_Y: int = 4
const GRID_SIZE_X: int = 4

static var _weighted_pool: Array[TetrominoType] = _build_weighted_pool()


static func _build_weighted_pool() -> Array:
	var pool: Array[TetrominoType] = []
	for type in TETROMINO_WEIGHTS.keys():
		var weight = TETROMINO_WEIGHTS[type]
		for i in range(weight):
			pool.append(type)
	return pool

static func get_random_tetromino_shape() -> TetrominoHelper.TetrominoType:
	#return _weighted_pool[randi() % _weighted_pool.size()]
	return TetrominoType.I
	
