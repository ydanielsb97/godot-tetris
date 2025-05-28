extends Node2D

@onready var logical_grid: Node2D = $LogicalGrid

const SINGLE_BLOCK = preload("res://scenes/blocks/single_block.tscn")

var tetromino_type: TetrominoHelper.TetrominoType
var grid: Array[GridCell] = []
const GRID_COLUMNS: int = 4
const GRID_ROWS: int = 4
const CELL_SIZE: int = 30
var blocks_offset: Vector2i

const GRID_SIZE_Y: int = 4
const GRID_SIZE_X: int = 4

const tetromino_offset := {
	TetrominoHelper.TetrominoType.I: Vector2i(30, -15),
	TetrominoHelper.TetrominoType.O: Vector2i(30, 30),
	TetrominoHelper.TetrominoType.T: Vector2i(15, 0),
	TetrominoHelper.TetrominoType.L: Vector2i(15, 0),
	TetrominoHelper.TetrominoType.J: Vector2i(15, 0),
	TetrominoHelper.TetrominoType.S: Vector2i(15, 0),
	TetrominoHelper.TetrominoType.Z: Vector2i(15, 0)
}

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
	
	block.position = Vector2((coords * CELL_SIZE))
	block.offset = tetromino_offset[tetromino_type]
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
	tetromino_type = tetromino_shape
	setup()

func setup() -> void:
	var tetromino = TetrominoHelper.TETROMINO_SHAPES[tetromino_type]
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
			final_positions.append(positions[0])
			continue
		
		var next_position_substract = positions[pos] - positions[pos - 1]
		final_positions.append(final_positions[pos - 1] + next_position_substract)
		
	for pos in final_positions:
		add_block(pos, tetromino["texture"])

func add_block(pos: Vector2i, block_texture: CompressedTexture2D) -> void:
	var new_block: SingleBlock = SINGLE_BLOCK.instantiate()
	logical_grid.add_child(new_block)
	new_block.setup(block_texture)
	add_block_to_grid(new_block, pos)

func get_cell_by_coords(coords: Vector2i) -> GridCell:
	var found_index: int = get_cell_index_by_coords(coords)
	
	if found_index == -1: return null
	
	return grid[found_index]

func get_cell_index_by_coords(coords: Vector2i) -> int:
	for index in range(len(grid)):
		if grid[index].coords == coords: return index
	return -1
