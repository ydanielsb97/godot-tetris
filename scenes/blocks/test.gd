extends Node2D

class_name Tetromino

enum TetrominoType {
	I,
	I_REVERSE,
	O,
	T,
	L,
	J,
	S,
	Z
}

const BLOCK_TEXTURES: Array[Texture2D] = [
	preload("res://assets/images/Tetromino_block1_2.png"),
	preload("res://assets/images/Tetromino_block1_3.png"),
	preload("res://assets/images/Tetromino_block1_4.png"),
	preload("res://assets/images/Tetromino_block1_5.png"),
	preload("res://assets/images/Tetromino_block1_6.png"),
	preload("res://assets/images/Tetromino_block1_7.png")
]

const FAST_FALL_FX = preload("res://scenes/blocks/fast_fall_fx.tscn")
const SINGLE_BLOCK = preload("res://scenes/blocks/single_block.tscn")
const TETROMINO_SHAPES := {
	TetrominoType.I: [
		[
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(2, 1),
			Vector2i(3, 1)
		],
		[
			Vector2i(0, 0),
			Vector2i(0, 1),
			Vector2i(0, 2),
			Vector2i(0, 3)
		]
	],
	TetrominoType.O: [
		[
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(1, 1),
			Vector2i(2, 1)
		]
	],
	TetrominoType.T: [
		[
			Vector2i(1, 0),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(2, 1)
		]
	],
	TetrominoType.L: [
		[
			Vector2i(2, 0),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(2, 1)
		]
	],
	TetrominoType.J: [
		[
			Vector2i(0, 0),
			Vector2i(0, 1),
			Vector2i(1, 1),
			Vector2i(2, 1)
		]
	],
	TetrominoType.S: [
		[
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(0, 1),
			Vector2i(1, 1)
		]
	],
	TetrominoType.Z: [
		[
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(1, 1),
			Vector2i(2, 1)
		]
	]
}

const BLOCK_SIZE: int = 30
const GRID_SIZE_Y: int = 4
const GRID_SIZE_X: int = 4

var block_texture: CompressedTexture2D
var relative_blocks: Array = []
var game_level: Node
var current_tetromino_shape: TetrominoType
var current_index_shape: int

signal landed

func _ready() -> void:
	block_texture = BLOCK_TEXTURES.pick_random()
	setup()

func setup() -> void:
	current_tetromino_shape = get_random_tetromino()
	current_tetromino_shape = TetrominoType.I
	
	current_index_shape = 0
	
	var random_tetromino: Array = TETROMINO_SHAPES[TetrominoType.I][current_index_shape]
	var current_cursor: Vector2i = Vector2i.ZERO
	
	for y in range(GRID_SIZE_Y):
		for x in range(GRID_SIZE_X):
			var pos = Vector2i(x, y)
			if pos in random_tetromino:
				add_block(pos)

func add_block(position: Vector2i) -> void:
	var new_block: SingleBlock = SINGLE_BLOCK.instantiate()
	add_child(new_block)
	new_block.position = BLOCK_SIZE * position
	new_block.setup(block_texture)
	relative_blocks.append(position)

func rotate_custom():
	
	for child in get_children():
		remove_child(child)
	
	var next_rotation: Array = get_next_rotation()
	var current_cursor: Vector2i = Vector2i.ZERO
	var rotated_positions: Array[Vector2i]
	
	for y in range(GRID_SIZE_Y):
		for x in range(GRID_SIZE_X):
			var pos = Vector2i(x, y)
			if pos in next_rotation:
				rotated_positions.append(Vector2i(BLOCK_SIZE * position))
				#add_block(pos)
	

	if is_valid_position(next_rotation):
		relative_blocks = next_rotation
		apply_positions()

func get_next_rotation() -> Array:
	var tetromino = TETROMINO_SHAPES[current_tetromino_shape]
	current_index_shape += 1
	return tetromino[current_index_shape % tetromino.size()]

func is_valid_position(rotated_blocks: Array) -> bool:
	var origin = Vector2i(position)

	for rel_pos in rotated_blocks:
		var world_pos = origin + rel_pos * BLOCK_SIZE

		var grid_x = int((world_pos.x - game_level.GRID_MARGING) / game_level.CELL_SIZE)
		var grid_y = int((world_pos.y - game_level.GRID_MARGING) / game_level.CELL_SIZE)
		
		if grid_x < 0 or grid_x >= game_level.GRID_WIDTH:
			return false
		if grid_y < 0 or grid_y >= game_level.GRID_HEIGHT:
			return false
			
		if game_level.grid[grid_y] and game_level.grid[grid_y].size() > grid_x and game_level.grid[grid_y][grid_x]:
			return false

	return true

func apply_positions():
	for child in get_children():
		remove_child(child)
	
	for y in range(GRID_SIZE_Y):
		for x in range(GRID_SIZE_X):
			var pos = Vector2i(x, y)
			if pos in relative_blocks:
				add_block(pos)

func get_bounding_rect() -> Rect2:
	var rect: Rect2
	var first := true

	for child: Sprite2D in get_children():
		var block_pos = child.position
		var block_size = child.texture.get_size() * child.scale

		var block_rect = Rect2(block_pos - block_size * 0.5, block_size)

		if first:
			rect = block_rect
			first = false
		else:
			rect = rect.merge(block_rect)
	
	return rect

func get_random_tetromino() -> TetrominoType:
	var values = TetrominoType.values()
	return values[randi() % values.size()]

func check_fire_exists() -> bool:
	for i in get_children(true):
		if i is FastFallFX: return true
	return false

func toggle_fire(activate: bool) -> void:
	var fire_exists = check_fire_exists()
	if activate and !fire_exists:
		var lower_position: Array[SingleBlock] = get_bottom_blocks()
		for block in lower_position:
			var new_fire_fx = FAST_FALL_FX.instantiate()
			#new_fire_fx.position += Vector2(5, 5)
			block.add_child(new_fire_fx, false, Node.INTERNAL_MODE_BACK)
		
	elif !activate and fire_exists:
		for i in get_children(true):
			if i is FastFallFX: remove_child(i)

func get_bottom_blocks() -> Array[SingleBlock]:
	var lower_position_block: SingleBlock
	var all_bottom_blocks: Array[SingleBlock]
	var all_children: Array[Node] = get_children()
	
	for single_block: SingleBlock in all_children:
		if lower_position_block == null: lower_position_block = single_block
		if single_block.position.y > lower_position_block.position.y: 
			lower_position_block = single_block
	
	for single_block: SingleBlock in all_children:
		if single_block.position.y == lower_position_block.position.y:
			all_bottom_blocks.append(single_block)
	
	return all_bottom_blocks
