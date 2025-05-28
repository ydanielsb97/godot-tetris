extends Node2D

@onready var logical_grid: Node2D = $Level/LogicalGrid
@onready var timer: Timer = $Level/Timer

const TETROMINO = preload("res://scenes/blocks/tetromino.tscn")

const CELL_SIZE = 30

const GRID_CONTAINER_MARGING = 15
const GRID_COLUMNS = 10
const GRID_HEIGHT = 20

const DEGREES_ROTATION: float = 90.0
const SOFT_DROP_SPEED: float = 0.0167
const HARD_DROP_SPEED: float = 0.005
const START_TETROMINO_POSITION: Vector2i = Vector2i(4, 2)

var current_tetromino: Tetromino
var next_tetromino_shape: TetrominoHelper.TetrominoType

var grid := []

var fastest_fall_speed: bool = false
var game_over: bool = false

var hold_left_timer := 0.0
var hold_right_timer := 0.0

const FIRST_HOLD_DELAY := 0.2  # Time before repeat starts
const HOLD_REPEAT_DELAY := 0.05  # Time between repeats

func _input(event: InputEvent) -> void:
	if current_tetromino == null or fastest_fall_speed:
		return

	if event.is_action_pressed("speed_up"):
		set_soft_speed()
		timer.start()

	if event.is_action_released("speed_up"):
		set_level_speed()
		timer.start()

	if event.is_action_pressed("turn"):
		current_tetromino.rotate_custom()
		SfxManager.play_sfx(SfxManager.SFX.ROTATE)

	if event.is_action_pressed("left"):
		current_tetromino.move_left()
		hold_left_timer = FIRST_HOLD_DELAY
		SfxManager.play_sfx(SfxManager.SFX.ROTATE)

	if event.is_action_pressed("right"):
		current_tetromino.move_right()
		hold_right_timer = FIRST_HOLD_DELAY
		SfxManager.play_sfx(SfxManager.SFX.ROTATE)

	if event.is_action_pressed("instant_fall"):
		activate_fastest_fall_speed()

func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		hold_left_timer -= delta
		if hold_left_timer <= 0:
			current_tetromino.move_left()
			hold_left_timer = HOLD_REPEAT_DELAY
	elif Input.is_action_pressed("right"):
		hold_right_timer -= delta
		if hold_right_timer <= 0:
			current_tetromino.move_right()
			hold_right_timer = HOLD_REPEAT_DELAY
	else:
		# reset both if neither is held
		hold_left_timer = 0
		hold_right_timer = 0

func activate_fastest_fall_speed() -> void:
	if fastest_fall_speed: return
	fastest_fall_speed = true
	timer.wait_time = HARD_DROP_SPEED
	timer.start()

func _ready() -> void:
	ScoreManager.start_score()
	next_tetromino_shape = TetrominoHelper.get_random_tetromino_shape()
	set_level_speed()
	draw_random_block()

func set_soft_speed() -> void:
	timer.wait_time = SOFT_DROP_SPEED
	SfxManager.play_sfx(SfxManager.SFX.HARD_DROP_ALT)

func set_level_speed() -> void:
	timer.wait_time = TetrominoHelper.get_level_speed()

func _enter_tree() -> void:
	GridManager.game_over.connect(on_game_over)
	GridManager.ready_to_add.connect(on_ready_to_add)
	
func on_ready_to_add() -> void:
	draw_random_block()
	timer.start()
	
func on_has_landed() -> void:
	timer.stop()
	reset_tetromino()
	GridManager.check_row_complete(current_tetromino.get_current_rows())

func draw_random_block() -> void:
	var new_tetromino = TETROMINO.instantiate()
	new_tetromino.setup(START_TETROMINO_POSITION, next_tetromino_shape)
	logical_grid.add_child(new_tetromino)
	current_tetromino = new_tetromino
	next_tetromino_shape = TetrominoHelper.get_random_tetromino_shape()
	SignalHub.emit_next_tetromino(next_tetromino_shape)

func reset_tetromino() -> void:
	if fastest_fall_speed:
		current_tetromino.toggle_fire(true)
		SfxManager.play_sfx(SfxManager.SFX.HARD_DROP)
	else:
		SfxManager.play_sfx(SfxManager.SFX.LANDING)
		
	fastest_fall_speed = false
	set_level_speed()

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
