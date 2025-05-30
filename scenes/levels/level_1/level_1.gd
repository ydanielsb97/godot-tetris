extends Node2D
@onready var logical_grid: Control = %LogicalGrid
@onready var main_color_rect: ColorRect = %MainCoverGrid
@onready var next_tetromino_color_rect: ColorRect = %NextTetrominoCoverGrid
@onready var press_start_label: Label = %PressStartLabel
@onready var paused_label: Label = %PausedLabel
@onready var game_over_stats_container: MarginContainer = %GameOverStatsContainer
@onready var animation_player: AnimationPlayer = $Level/GameUI/HBoxContainer/HBoxContainer/CenterContainer/Center/MainGrid/CenterContainer/TextureRect/AnimationPlayer

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

var checking_has_landed: bool = false
var hold_left_timer := 0.0
var hold_right_timer := 0.0
const FIRST_HOLD_DELAY := 0.2  # Time before repeat starts
const HOLD_REPEAT_DELAY := 0.05  # Time between repeats
const INPUT_DELAY: float = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if cant_handle_input(): return

	if event.is_action_pressed("speed_up"):
		GameManager.set_soft_drop_speed()

	if event.is_action_released("speed_up"):
		GameManager.set_level_speed()

	rotate_tetromino(Input.get_axis("turn_counter_clockwise", "turn_clockwise"))
	
	move_horizontally(Input.get_axis("left", "right"))

	if event.is_action_pressed("instant_fall"):
		GameManager.set_hard_drop_speed()

func move_horizontally(is_left: int) -> void:
	if cant_handle_input() or is_left == 0: return
	
	var moved: bool
	
	if is_left < 0:
		moved = current_tetromino.move_left()
		hold_left_timer = FIRST_HOLD_DELAY
	else:
		moved = current_tetromino.move_right()
		hold_right_timer = FIRST_HOLD_DELAY
		
	if moved: SfxManager.play_sfx(SfxManager.SFX.ROTATE)

func cant_handle_input() -> bool:
	return current_tetromino == null or GameManager.hard_drop

func rotate_tetromino(is_clockwise) -> void:
	if cant_handle_input() or is_clockwise == 0: return
	
	var rotated = current_tetromino.rotate_custom(is_clockwise)
	if rotated: SfxManager.play_sfx(SfxManager.SFX.ROTATE)

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
	SignalHub.rows_destroyed.connect(on_rows_destroyed)

func on_rows_destroyed(rows: int) -> void:
	if rows == 4:
		animation_player.play("tetris_flash")

func on_game_paused(paused: bool) -> void:
	handle_paused_message(paused)

func on_game_over() -> void:
	show_overlay()
	game_over_stats_container.show()

func _ready() -> void:
	GameManager.timer.timeout.connect(_on_timer_timeout)
	
	show_all_mobile_controls(is_mobile())

func show_all_mobile_controls(show: bool) -> void:
	for node in get_tree().get_nodes_in_group("mobile_controls"):
		if show: node.show() 
		else: node.hide()

func is_mobile() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")

func on_ready_to_add_block() -> void:
	draw_random_block()
	GameManager.set_level_speed()
	checking_has_landed = false

func has_landed() -> void:
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
	if GameManager.game_over or !current_tetromino or checking_has_landed: return
	
	checking_has_landed = true
	if current_tetromino.check_has_landed():
		has_landed()
	else:
		if GameManager.hard_drop:
			current_tetromino.move_down() # move twice each tick when is fast fall to add smoothness
		current_tetromino.move_down()
		checking_has_landed = false

func _on_texture_button_button_down() -> void:
	if cant_handle_input(): return
	rotate_tetromino(1)

func _on_texture_button_2_button_down() -> void:
	if cant_handle_input(): return
	GameManager.set_hard_drop_speed()


func _on_move_left_button_button_down() -> void:
	if cant_handle_input(): return
	move_horizontally(-1)


func _on_move_right_button_button_down() -> void:
	if cant_handle_input(): return
	move_horizontally(1)


func _on_speed_up_button_button_down() -> void:
	if cant_handle_input(): return
	GameManager.set_soft_drop_speed()


func _on_move_right_button_pressed() -> void:
	if cant_handle_input(): return
	move_horizontally(1)


func _on_enter_button_button_down() -> void:
	if cant_handle_input(): return
	GameManager.handle_start_action()


func _on_speed_up_button_button_up() -> void:
	if cant_handle_input(): return
	GameManager.set_level_speed()
