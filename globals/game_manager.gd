extends Node

var timer: Timer

var game_over: bool = false
var game_started: bool = false
var game_paused: bool = false
var hard_drop: bool = false

const HARD_DROP_SPEED: float = 0.005
const SOFT_DROP_SPEED: float = 0.0167

func _enter_tree() -> void:
	SignalHub.game_over.connect(on_game_over)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer = Timer.new()
	timer.one_shot = false
	timer.autostart = false
	timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(timer)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("start"):
		if !game_started or game_over:
			start_game()
		else:
			pause_game()

func pause_game() -> void:
	if game_over: return
	game_paused = !game_paused
	get_tree().paused = game_paused
	SignalHub.emit_game_paused(game_paused)

func start_game() -> void:
	GridManager.clear_grid()
	game_started = true
	game_over = false
	game_paused = false
	hard_drop = false
	ScoreManager.start_score()
	set_level_speed()
	SignalHub.emit_game_start()
	start_timer()

func start_timer() -> void:
	timer.start()

func stop_timer() -> void:
	timer.stop()

func set_soft_drop_speed() -> void:
	if hard_drop: return
	timer.wait_time = SOFT_DROP_SPEED
	start_timer()
	SfxManager.play_sfx(SfxManager.SFX.HARD_DROP_ALT)

func set_level_speed() -> void:
	timer.wait_time = TetrominoHelper.get_level_speed()
	hard_drop = false
	start_timer()

func set_hard_drop_speed() -> void:
	if hard_drop: return
	hard_drop = true
	timer.wait_time = HARD_DROP_SPEED
	start_timer()

func on_game_over(): 
	game_over = true
	stop_timer()
