extends Node

const CELL_SIZE: int = 30
const GRID_MARGING: Vector2i = Vector2i(-15, -15)
const GRID_COLUMNS: int = 10
const GRID_ROWS: int = 22
const TWEEN_SPEED_MOVEMENT: float = 0.0
const TWEEN_SPEED_TO_DIRECTION: float = 0.0

var grid: Array[GridCell] = []

func _ready() -> void:
	for x in range(GRID_COLUMNS):
		for y in range(GRID_ROWS):
			var new_cell: GridCell = GridCell.new()
			new_cell.set_coords(Vector2(x, y))
			grid.append(new_cell)

func clear_grid() -> void:
	for cell in grid:
		if cell.block: cell.block.queue_free()
		cell.set_block(null)

func add_block(block: SingleBlock, coords: Vector2i) -> void:
	var cell_grid = get_cell_by_coords(coords)
	
	if !cell_grid: return
	elif cell_grid.block != null: 
		SignalHub.emit_game_over()
		return
	
	block.position = Vector2(coords * CELL_SIZE - GRID_MARGING)
	cell_grid.set_block(block)
	
	# Check landed on addition
	var cell_to = get_cell_by_coords(cell_grid.coords + Vector2i.DOWN)
	if cell_to and cell_to.block:
		SignalHub.emit_has_landed()

func check_cell_is_empty(coords: Vector2i) -> bool:
	var cell_grid = get_cell_by_coords(coords)
	return !cell_grid or cell_grid.block

func move_block(from: Vector2i, to: Vector2i) -> bool:
	var cell_grid = get_cell_by_coords(to)
	if !cell_grid or cell_grid.block: return false
	
	var cell_grid_to = get_cell_by_coords(to)
	var cell_grid_from = get_cell_by_coords(from)
	
	var block = cell_grid_from.block
	if !block: return false
	var tween = create_tween().set_parallel()
	tween.tween_property(block, "position", Vector2(to * CELL_SIZE - GRID_MARGING), TWEEN_SPEED_MOVEMENT)
	cell_grid_to.set_block(block)
	cell_grid_from.set_block(null)
	
	return true

func move_group_blocks_to_direction(from: Array[Vector2i], to: Vector2i, tween_time: float = TWEEN_SPEED_TO_DIRECTION) -> bool:
	var all_cells_from: Array[GridCell]
	for from_one in from:
		var cell_from = get_cell_by_coords(from_one)
		if cell_from == null or cell_from.block == null: return false
		
		all_cells_from.append(cell_from)
	
	match to:
		Vector2i.DOWN:
			all_cells_from.sort_custom(func(a, b): return a.coords.y > b.coords.y)
		Vector2i.RIGHT:
			all_cells_from.sort_custom(func(a, b): return a.coords.x > b.coords.x)
		Vector2i.LEFT:
			all_cells_from.sort_custom(func(a, b): return b.coords.x > a.coords.x)

	var all_cells_to: Array[GridCell]
	
	for cell in all_cells_from:
		var cell_to = get_cell_by_coords(cell.coords + to)
		if cell_to == null: return false
		var block_exists_in_from: int = - 1
		
		for index in range(len(all_cells_from)):
			if all_cells_from[index].coords == cell_to.coords: block_exists_in_from = index
		
		if cell_to.block != null and block_exists_in_from == -1:
			return false
		elif cell_to.coords.x < 0 or cell_to.coords.x >= GRID_COLUMNS or cell_to.coords.y < 0 or cell_to.coords.y >= GRID_ROWS:
			return false
		
		all_cells_to.append(cell_to)
		
	#var tween = create_tween().set_parallel()
	
	for index in range(len(all_cells_from)):
		var cell = all_cells_from[index]
		var cell_to = all_cells_to[index]
		cell.block.position = Vector2(cell_to.coords * CELL_SIZE - GRID_MARGING)
		cell.block.visible = cell_to.coords.y >= 2
		
		cell_to.set_block(cell.block)
		cell.set_block(null)
#
	#await tween.finished
	
	return true

func reduce_get_blocks_from_cells(acc: Array[SingleBlock], current: GridCell) -> Array[SingleBlock]: 
		acc.append(current.block)
		return acc

func move_group_blocks(from: Array[Vector2i], to: Array[Vector2i]) -> bool:
	var all_cells_from: Array[GridCell]
	var all_cells_to: Array[GridCell]
	
	for index in range(len(from)):
		var cell_from = get_cell_by_coords(from[index])
		var cell_to = get_cell_by_coords(to[index])
		
		if cell_from == null or cell_to == null or cell_from.block == null or cell_to == null: return false
		
		all_cells_from.append(cell_from)
		all_cells_to.append(cell_to)
	
	for cell_to in all_cells_to:
		if cell_to == null: return false
		var block_exists_in_from: bool = false
		
		for cell_from in all_cells_from:
			if cell_from.coords == cell_to.coords: 
				block_exists_in_from = true
				break
		
		if cell_to.block != null and !block_exists_in_from:
			return false
		elif cell_to.coords.x < 0 or cell_to.coords.x >= GRID_COLUMNS or cell_to.coords.y < 0 or cell_to.coords.y >= GRID_ROWS:
			return false
	
	var initial_blocks_array: Array[SingleBlock] = []
	var all_blocks_to_move: Array[SingleBlock] = all_cells_from.reduce(reduce_get_blocks_from_cells, initial_blocks_array)
	
	for index in range(len(all_cells_to)):
		var cell_to = all_cells_to[index]
		var block = all_blocks_to_move[index]
		var tween = create_tween()
		tween.tween_property(block, "position", Vector2(cell_to.coords * CELL_SIZE - GRID_MARGING), TWEEN_SPEED_MOVEMENT)
		block.visible = cell_to.coords.y >= 2
		cell_to.set_block(block)
	
	for cell_from in all_cells_from:
		if cell_from not in all_cells_to:
			cell_from.set_block(null)
	
	return true

func check_if_landed(coord_list: Array[Vector2i]) -> bool:
	var cells_to_check: Array[GridCell]
	for coords in coord_list:
		cells_to_check.append(get_cell_by_coords(coords))
		
		var cell = get_cell_by_coords(coords)
		var cell_to = get_cell_by_coords(cell.coords + Vector2i.DOWN)
		if cell_to == null:
			return true
		
		var block_belongs_to_origin = coord_list.find(cell_to.coords)
		
		if cell_to.block and block_belongs_to_origin == -1: 
			return true
		elif cell_to.coords.x < 0 or cell_to.coords.x >= GRID_COLUMNS or cell_to.coords.y < 0 or cell_to.coords.y >= GRID_ROWS:
			return true

	return false

func destroy_block(coords: Vector2i) -> void:
	var cell_grid_index = get_cell_index_by_coords(coords)
	
	if grid[cell_grid_index].block != null: return
	grid[cell_grid_index].destroy_block()

func check_row_complete(rows_to_check: Array[int]) -> void:
	var rows_to_delete: Array[int] = []
	
	for row in rows_to_check:
		var count = 0
		for column in range(GRID_COLUMNS):
			if get_cell_by_coords(Vector2i(column, row)).block:
				count += 1
		if count == GRID_COLUMNS:
			rows_to_delete.append(row)
	
	if len(rows_to_delete) <= 0:
		SignalHub.emit_ready_to_add_block()
		return
	
	var higher_animation_time: float = 0.0
	
	for row in rows_to_delete:
		higher_animation_time = destroy_row(row)
		
	SignalHub.emit_rows_destroyed(len(rows_to_delete))
	ScoreManager.register_clear(len(rows_to_delete))
	
	await get_tree().create_timer(higher_animation_time / 2).timeout
	
	for row in rows_to_delete:
		await move_down_from_row(row)

	SignalHub.emit_ready_to_add_block()

func destroy_row(row: int) -> float:
	var higher_animation_time: float = 0.0
	
	for x in range(GRID_COLUMNS):
		var cell = get_cell_by_coords(Vector2i(x, row))
		if cell.block.animation_length > higher_animation_time: 
			higher_animation_time = cell.block.animation_length
		
		cell.destroy_block()
	return higher_animation_time

func move_down_from_row(row_from: int) -> void:
	var positions_from: Array[Vector2i] = []
	for current_row in range(0, row_from):
		for x in range(GRID_COLUMNS):
			var coords: Vector2i = Vector2i(x, current_row)
			if get_cell_by_coords(coords).block:
				positions_from.append(Vector2i(x, current_row))
	
	if positions_from.is_empty(): return
	var is_moved = await move_group_blocks_to_direction(positions_from, Vector2i.DOWN, 0.00)
	
	while is_moved:
		for index in len(positions_from):
			positions_from[index] += Vector2i.DOWN
		is_moved = await move_group_blocks_to_direction(positions_from, Vector2i.DOWN, 0.00)

func get_cell_by_coords(coords: Vector2i) -> GridCell:
	var found_index: int = get_cell_index_by_coords(coords)
	
	if found_index == -1: return null
	
	return grid[found_index]

func get_cell_index_by_coords(coords: Vector2i) -> int:
	for index in range(len(grid)):
		if grid[index].coords == coords: return index
	return -1
