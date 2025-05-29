extends Node2D

@onready var logical_grid: Control = $Level/GameUI/HBoxContainer/CenterContainer/Center/MainGrid/LogicalGrid
@onready var main_color_rect: ColorRect = %MainCoverGrid
@onready var next_tetromino_color_rect: ColorRect = %NextTetrominoCoverGrid
@onready var press_start_label: Label = %PressStartLabel
@onready var paused_label: Label = %PausedLabel
@onready var game_over_stats_container: MarginContainer = %GameOverStatsContainer

const OVERLAY_COLOR: Color = Color("113448")
const DEFAULT_OVERLAY_COLOR: Color = Color("00000088")
const TETROMINO = preload("res://scenes/blocks/tetromino.tscn")
const CELL_SIZE = 30
const GRID_CONTAINER_MARGING = 15
const GRID_COLUMNS = 10
const GRID_HEIGHT = 20

const START_TETROMINO_POSITION: Vector2i = Vector2i(4, 2)

var current_tetromino: Tetromino
var next_tetromino_shape: TetrominoHelper.TetrominoType

var grid := []

var hold_left_timer := 0.0
var hold_right_timer := 0.0
const FIRST_HOLD_DELAY := 0.2  # Time before repeat starts
const HOLD_REPEAT_DELAY := 0.05  # Time between repeats

func _input(event: InputEvent) -> void:

	if current_tetromino == null or GameManager.hard_drop:
		return

	if event.is_action_pressed("speed_up"):
		GameManager.set_soft_drop_speed()

	if event.is_action_released("speed_up"):
		GameManager.set_level_speed()

	if event.is_action_pressed("turn"):
		var rotated = current_tetromino.rotate_custom()
		if rotated: SfxManager.play_sfx(SfxManager.SFX.ROTATE)

	if event.is_action_pressed("left"):
		var moved = current_tetromino.move_left()
		hold_left_timer = FIRST_HOLD_DELAY
		if moved: SfxManager.play_sfx(SfxManager.SFX.ROTATE)

	if event.is_action_pressed("right"):
		var moved = current_tetromino.move_right()
		hold_right_timer = FIRST_HOLD_DELAY
		if moved: SfxManager.play_sfx(SfxManager.SFX.ROTATE)

	if event.is_action_pressed("instant_fall"):
		GameManager.set_hard_drop_speed()

func _process(delta: float) -> void:
	if current_tetromino == null or GameManager.hard_drop:
		return
	if Input.is_action_pressed("left"):
		hold_left_timer -= delta
		if hold_left_timer <= 0:
			var moved = current_tetromino.move_left()
			hold_left_timer = HOLD_REPEAT_DELAY
			if moved: SfxManager.play_sfx(SfxManager.SFX.ROTATE)
	elif Input.is_action_pressed("right"):
		hold_right_timer -= delta
		if hold_right_timer <= 0:
			var moved = current_tetromino.move_right()
			hold_right_timer = HOLD_REPEAT_DELAY
			if moved: SfxManager.play_sfx(SfxManager.SFX.ROTATE)
	else:
		hold_left_timer = 0
		hold_right_timer = 0

func on_game_start() -> void:
	hide_overlay()
	press_start_label.hide()
	game_over_stats_container.hide()
	next_tetromino_shape = TetrominoHelper.get_random_tetromino_shape()
	draw_random_block()

func _enter_tree() -> void:
	SignalHub.ready_to_add_block.connect(on_ready_to_add_block)
	SignalHub.game_start.connect(on_game_start)
	SignalHub.game_paused.connect(on_game_paused)
	SignalHub.game_over.connect(on_game_over)

func on_game_paused(paused: bool) -> void:
	handle_paused_message(paused)

func on_game_over() -> void:
	show_overlay()
	game_over_stats_container.show()

func _ready() -> void:
	GameManager.timer.timeout.connect(_on_timer_timeout)

func on_ready_to_add_block() -> void:
	draw_random_block()
	GameManager.start_timer()

func on_has_landed() -> void:
	GameManager.stop_timer()
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
	if GameManager.hard_drop:
		current_tetromino.toggle_fire(true)
		SfxManager.play_sfx(SfxManager.SFX.HARD_DROP)
	else:
		SfxManager.play_sfx(SfxManager.SFX.LANDING)
		
	GameManager.hard_drop = false
	GameManager.set_level_speed()

func handle_paused_message(show: bool) -> void:
	if show:
		press_start_label.show()
		paused_label.show()
		show_overlay()
	else:
		press_start_label.hide()
		paused_label.hide()
		hide_overlay()

func show_overlay() -> void:
	main_color_rect.z_index = 1
	next_tetromino_color_rect.z_index = 1
	main_color_rect.color = OVERLAY_COLOR
	next_tetromino_color_rect.color = OVERLAY_COLOR

func hide_overlay() -> void:
	main_color_rect.z_index = 0
	next_tetromino_color_rect.z_index = 0
	main_color_rect.color = DEFAULT_OVERLAY_COLOR
	next_tetromino_color_rect.color = DEFAULT_OVERLAY_COLOR

func _on_timer_timeout() -> void:
	if GameManager.game_over or !current_tetromino: return
	
	if current_tetromino.check_has_landed():
		on_has_landed()
	else:
		if GameManager.hard_drop:
			current_tetromino.move_down() # move twice each tick when is fast fall to add smoothness
		current_tetromino.move_down()
