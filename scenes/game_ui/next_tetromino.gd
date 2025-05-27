extends Node2D

@onready var logical_grid: Node2D = $LogicalGrid

const SINGLE_BLOCK = preload("res://scenes/blocks/single_block.tscn")

var grid: Array[GridCell] = []
const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 4
const CELL_SIZE: int = 30
const GRID_MARGIN: Vector2i = Vector2i(-30, 0)
var grid_margin: Vector2i

const GRID_SIZE_Y: int = 4
const GRID_SIZE_X: int = 4

func _ready() -> void:
	for x in range(GRID_COLUMNS):
		for y in range(GRID_ROWS):
			var new_cell: GridCell = GridCell.new()
			new_cell.set_coords(Vector2(x, y))
			grid.append(new_cell)

func add_block_to_grid(block: SingleBlock, coords: Vector2i) -> void:
	var cell_grid = get_cell_by_coords(coords)
	
	if !cell_grid: return
	elif cell_grid.block != null: 
		return
	
	block.position = Vector2((coords * CELL_SIZE) - grid_margin)
	cell_grid.set_block(block)

func clear_cells() -> void:
	for cell in grid:
		cell.destroy_block()
	for child in logical_grid.get_children():
		child.queue_free()

func _enter_tree() -> void:
	SignalHub.next_tetromino.connect(on_next_tetromino)

func on_next_tetromino(tetromino_shape: TetrominoHelper.TetrominoType) -> void:
	clear_cells()
	setup(tetromino_shape)

func setup(tetromino_shape: TetrominoHelper.TetrominoType) -> void:
	
	var tetromino = TetrominoHelper.TETROMINO_SHAPES[tetromino_shape]
	var first_coords: Array = tetromino["coords"][0]
	
	var positions: Array[Vector2i] = []
	
	for y in range(GRID_SIZE_Y):
		for x in range(GRID_SIZE_X):
			var pos = Vector2i(x, y)
			if pos in first_coords:
				positions.append(pos)
		
	var final_positions: Array[Vector2i] = []
	
	for pos in len(positions):
		if pos == 0:
			final_positions.append(Vector2i(0, 0))
			continue
		
		var next_position_substract = positions[pos] - positions[pos - 1]
		final_positions.append(final_positions[pos - 1] + next_position_substract)
	
	grid_margin = calculate_margin_for_shape(final_positions)
	
	for pos in final_positions:
		add_block(pos, tetromino["texture"])

func add_block(pos: Vector2i, block_texture: CompressedTexture2D) -> void:
	var new_block: SingleBlock = SINGLE_BLOCK.instantiate()
	logical_grid.add_child(new_block)
	new_block.setup(block_texture)
	add_block_to_grid(new_block, pos)

func calculate_margin_for_shape(shape: Array) -> Vector2i:
	
	var higher_x: int = 0
	var higher_y: int = 0
	
	for coord:Vector2i in shape:
		higher_x = coord.x if coord.x > higher_x else higher_x
		higher_y = coord.y if coord.y > higher_y else higher_y
	
	var empty_x: int = (higher_x + 1) - GRID_COLUMNS
	var empty_y: int = (higher_y + 1) - GRID_ROWS
	
	var margin_x: int = empty_x * (CELL_SIZE / 2)
	var margin_y: int = empty_y * (CELL_SIZE / 2)
	
	return GRID_MARGIN + Vector2i(margin_x, margin_y)

	
func get_cell_by_coords(coords: Vector2i) -> GridCell:
	var found_index: int = get_cell_index_by_coords(coords)
	
	if found_index == -1: return null
	
	return grid[found_index]

func get_cell_index_by_coords(coords: Vector2i) -> int:
	for index in range(len(grid)):
		if grid[index].coords == coords: return index
	return -1
