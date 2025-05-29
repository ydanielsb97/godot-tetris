extends MarginContainer

@onready var score_value_label: Label = $VBoxContainer/ScoreContainer/ScoreValueLabel
@onready var lines_value_label: Label = $VBoxContainer/LinesClearedContainer/LinesValueLabel
@onready var level_value_label: Label = $VBoxContainer/LevelContainer/LevelValueLabel
@onready var single_value_label: Label = $VBoxContainer/SingleContainer/SingleValueLabel
@onready var double_value_label: Label = $VBoxContainer/DoubleContainer/DoubleValueLabel
@onready var triple_value_label: Label = $VBoxContainer/TripleContainer/TripleValueLabel
@onready var tetris_value_label: Label = $VBoxContainer/TetrisContainer/TetrisValueLabel
@onready var high_score_label: Label = $VBoxContainer/HBoxContainer/HighScoreLabel

func _enter_tree() -> void:
	SignalHub.game_over.connect(on_game_over)

func on_game_over() -> void:
	score_value_label.text = "%06d" % ScoreManager.current_score.score
	lines_value_label.text = "%03d" % ScoreManager.current_score.lines_cleared
	level_value_label.text = "%02d" % ScoreManager.current_score.level
	
	if ScoreManager.current_score.lines_simultaneously["single"]:
		single_value_label.text = "%03d" % ScoreManager.current_score.lines_simultaneously["single"]
	else:
		single_value_label.text = "-"
		
	if ScoreManager.current_score.lines_simultaneously["double"]:
		double_value_label.text = "%03d" % ScoreManager.current_score.lines_simultaneously["double"]
	else:
		double_value_label.text = "-"
	
	
	if ScoreManager.current_score.lines_simultaneously["triple"]:
		triple_value_label.text = "%03d" % ScoreManager.current_score.lines_simultaneously["triple"]
	else:
		triple_value_label.text = "-"
		
	if ScoreManager.current_score.lines_simultaneously["tetris"]:
		tetris_value_label.text = "%03d" % ScoreManager.current_score.lines_simultaneously["tetris"]
	else:
		tetris_value_label.text = "-"
	
	high_score_label.visible = ScoreManager.is_high_score
