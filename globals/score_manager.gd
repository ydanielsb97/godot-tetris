extends Node

var high_score: HighScoreResource
var current_score: HighScoreResource

func _ready() -> void:
	high_score = HighScoreResource.load_high_score()

func start_score() -> void:
	current_score = HighScoreResource.new()
	SignalHub.emit_score_update()
	
func register_clear(lines_cleared: int):
	var points: int = 0
	
	match lines_cleared:
		1: 
			points = 40
			current_score.lines_simultaneously["single"] += 1
			SfxManager.play_sfx(SfxManager.SFX.SINGLE)
		2: 
			points = 100
			current_score.lines_simultaneously["double"] += 1
			SfxManager.play_sfx(SfxManager.SFX.DOUBLE)
		3: 
			points = 300
			current_score.lines_simultaneously["triple"] += 1
			SfxManager.play_sfx(SfxManager.SFX.TRIPLE)
		4: 
			points = 1200
			current_score.lines_simultaneously["tetris"] += 1
			SfxManager.play_sfx(SfxManager.SFX.TETRIS)
	
	current_score.score += points * (current_score.level + 1)
	current_score.lines_cleared += lines_cleared
	
	update_level()
	
	var is_high_score: bool = current_score.save_score(high_score)
	
	if is_high_score:
		high_score = current_score
	
	SignalHub.emit_score_update()

func update_level() -> void:
	var new_level = current_score.lines_cleared / 10
	
	if new_level > current_score.level:
		current_score.level = new_level
		# Emit level up to change blocks colors
