extends Node2D

class_name Tetromino

const FAST_FALL_FX = preload("res://scenes/blocks/fast_fall_fx.tscn")
const SINGLE_BLOCK = preload("res://scenes/blocks/single_block.tscn")

const GRID_SIZE_Y: int = 4
const GRID_SIZE_X: int = 4

var block_texture: CompressedTexture2D
var relative_blocks: Array = []
var game_level: Node
var current_tetromino_shape: TetrominoHelper.TetrominoType
var current_index_shape: int = 0
var is_locked: bool = false

func setup(coords_grid: Vector2i, tetromino_shape: TetrominoHelper.TetrominoType) -> void:
	
	current_tetromino_shape = tetromino_shape
	var tetromino = TetrominoHelper.TETROMINO_SHAPES[current_tetromino_shape]
	
	block_texture = tetromino["texture"]
	var random_tetromino: Array = tetromino["coords"][current_index_shape]
	
	var positions: Array[Vector2i] = []
	
	for y in range(GRID_SIZE_Y):
		for x in range(GRID_SIZE_X):
			var pos = Vector2i(x, y)
			if pos in random_tetromino:
				positions.append(pos)
				#add_block(pos, coords_grid)
		
	var final_positions: Array[Vector2i] = []
	
	if current_tetromino_shape == TetrominoHelper.TetrominoType.I:
		coords_grid -= Vector2i(1,0)
		
	if current_tetromino_shape == TetrominoHelper.TetrominoType.S:
		coords_grid += Vector2i(1,0)
		
	for pos in len(positions):
		if pos == 0:
			final_positions.append(coords_grid)
			continue
		
		var next_position_substract = positions[pos] - positions[pos - 1]
		final_positions.append(final_positions[pos - 1] + next_position_substract)

	for pos in final_positions:
		add_block(pos)

func add_block(pos: Vector2i) -> void:
	var new_block: SingleBlock = SINGLE_BLOCK.instantiate()
	add_child(new_block)
	new_block.setup(block_texture)
	GridManager.add_block(new_block, pos)

func move_down() -> bool:
	return move(Vector2i.DOWN)
	
func move_left() -> bool:
	return move(Vector2i.LEFT)

func move_right() -> bool:
	return move(Vector2i.RIGHT)

func move(target_direction: Vector2i) -> bool:
	var all_coords: Array[Vector2i]

	for child: SingleBlock in get_children():
		all_coords.append(child.grid_coords)	
	return GridManager.move_group_blocks_to_direction(all_coords, target_direction)

func rotate_custom(next_index_to_sum: int) -> bool:
	var all_coords: Array[Vector2i]

	for child: SingleBlock in get_children():
		all_coords.append(child.grid_coords)
		
	var tetromino = TetrominoHelper.TETROMINO_SHAPES[current_tetromino_shape]["coords"]
	var array_coords = tetromino[current_index_shape % tetromino.size()]
	
	var next_rotation: Array[Vector2i] = get_next_rotation(next_index_to_sum)
	
	for index in range(len(next_rotation)):
		var val1 = all_coords[index] - array_coords[index]
		next_rotation[index] += val1
	
	var changed = GridManager.move_group_blocks(all_coords, next_rotation)
	if !changed: current_index_shape = current_index_shape + (next_index_to_sum * -1)
	return changed

func get_next_rotation(index_to: int) -> Array[Vector2i]:
	var tetromino = TetrominoHelper.TETROMINO_SHAPES[current_tetromino_shape]["coords"]
	current_index_shape = current_index_shape + index_to
	var array_coords: Array = tetromino[current_index_shape % tetromino.size()]
	var new_array_cords: Array[Vector2i] = []
	new_array_cords.assign(array_coords.map(func (v): return v as Vector2i))
	return new_array_cords

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

func activate_fire() -> void:
	var lower_position: Array[SingleBlock] = get_bottom_blocks()
	for block in lower_position:
		var new_fire_fx = FAST_FALL_FX.instantiate()
		block.add_child(new_fire_fx, false, Node.INTERNAL_MODE_BACK)

func check_has_landed() -> bool:
	var all_coords: Array[Vector2i]

	for child: SingleBlock in get_children():
		all_coords.append(child.grid_coords)
	
	return GridManager.check_if_landed(all_coords)

func get_bottom_blocks() -> Array[SingleBlock]:
	var lower_position_block: SingleBlock = null
	var all_bottom_blocks: Array[SingleBlock]
	var all_children: Array[Node] = get_children()
	
	for single_block: SingleBlock in all_children:
		if lower_position_block == null: lower_position_block = single_block
		elif single_block.grid_coords.y > lower_position_block.grid_coords.y: 
			lower_position_block = single_block
	
	for single_block: SingleBlock in all_children:
		if single_block.grid_coords.y == lower_position_block.grid_coords.y:
			all_bottom_blocks.push_back(single_block)
	
	return all_bottom_blocks

func get_current_rows() -> Array[int]:
	var all_rows: Array[int]

	for child: SingleBlock in get_children():
		if child.grid_coords.y not in all_rows:
			all_rows.append(child.grid_coords.y)
	
	return all_rows
