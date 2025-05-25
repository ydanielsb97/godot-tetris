extends Node2D

class_name GridCell

var block: SingleBlock
var coords: Vector2i

func set_coords(c: Vector2i) -> void:
	coords = c

func set_block(b: SingleBlock) -> void:
	block = b
	if !block: return
	block.grid_coords = coords

func destroy_block() -> void:
	block.destroy()
	block = null
