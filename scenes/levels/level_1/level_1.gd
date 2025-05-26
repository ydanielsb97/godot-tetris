extends Node2D

@onready var logical_grid: Node2D = $Level/LogicalGrid
@onready var timer: Timer = $Level/Timer

const TETROMINO = preload("res://scenes/blocks/tetromino.tscn")

const CELL_SIZE = 30

const GRID_CONTAINER_MARGING = 15
const GRID_COLUMNS = 10
const GRID_HEIGHT = 20

const DEGREES_ROTATION: float = 90.0
const DEFAULT_FALLING_TIME: float = 1.0
const START_TETROMINO_POSITION: Vector2i = Vector2i(3, 0)

var current_tetromino: Tetromino
var next_tetromino_shape: TetrominoHelper.TetrominoType

var grid := []

var fastest_fall_speed: bool = false
var fast_fall_speed: bool = false
var timer_wait_time: float = .5
var game_over: bool = false

func _input(event: InputEvent) -> void:
	if current_tetromino == null or fastest_fall_speed:
		return
	
	if event.is_action_pressed("speed_up"):
		timer_wait_time = 0.02
		timer.wait_time = timer_wait_time
		timer.start()
	
	if event.is_action_released("speed_up"):
		timer_wait_time = DEFAULT_FALLING_TIME
		timer.wait_time = timer_wait_time
		timer.start()
	
	if event.is_action_pressed("turn"):
		current_tetromino.rotate_custom()
		
	if event.is_action_pressed("left"):
		current_tetromino.move_left()
	elif event.is_action_pressed("right"):
		current_tetromino.move_right()
	elif event.is_action_pressed("instant_fall"):
		activate_fastest_fall_speed()

func activate_fastest_fall_speed() -> void:
	if fastest_fall_speed: return
	fastest_fall_speed = true
	timer_wait_time = 0.01
	timer.wait_time = timer_wait_time
	timer.start()

func _ready() -> void:
	next_tetromino_shape = TetrominoHelper.get_random_tetromino_shape()
	draw_random_block()

func _enter_tree() -> void:
	GridManager.game_over.connect(on_game_over)
	GridManager.ready_to_add.connect(on_ready_to_add)
	
func on_ready_to_add() -> void:
	draw_random_block()
	timer.start()
	
func on_has_landed() -> void:
	timer.stop()
	if fastest_fall_speed:
		current_tetromino.toggle_fire(true)
	GridManager.check_row_complete(current_tetromino.get_current_rows())
	reset_tetromino()
	timer_wait_time = DEFAULT_FALLING_TIME
	timer.wait_time = timer_wait_time

func draw_random_block() -> void:
	var new_tetromino = TETROMINO.instantiate()
	new_tetromino.setup(START_TETROMINO_POSITION, next_tetromino_shape)
	logical_grid.add_child(new_tetromino)
	current_tetromino = new_tetromino
	next_tetromino_shape = TetrominoHelper.get_random_tetromino_shape()
	SignalHub.emit_next_tetromino(next_tetromino_shape)

func reset_tetromino() -> void:
	fastest_fall_speed = false
	current_tetromino = null

func _on_timer_timeout() -> void:
	if game_over or !current_tetromino: return
	
	if current_tetromino.check_has_landed():
		on_has_landed()
	else:
		if fastest_fall_speed:
			current_tetromino.move_down() # move twice each tick when is fast fall to add smoothness
		current_tetromino.move_down()

func on_game_over(): 
	if get_tree():
		get_tree().reload_current_scene()
		game_over = true
		timer.stop()
