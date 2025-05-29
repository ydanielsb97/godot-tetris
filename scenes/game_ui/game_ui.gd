extends Control

@onready var lines_label: Label = %LinesLabel
@onready var top_value_label: Label = %TopValueLabel
@onready var score_value_label: Label = %ScoreValueLabel
@onready var level_value_label: Label = %LevelValueLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalHub.score_update.connect(on_score_update)
	update_high_score()

func on_score_update() -> void:
	update_high_score()
	update_current_score()

func update_high_score() -> void:
	if ScoreManager.high_score:
		top_value_label.text = "%06d" % ScoreManager.high_score.score

func update_current_score() -> void:
	if ScoreManager.current_score:
		lines_label.text = "LINES - %03d" % ScoreManager.current_score.lines_cleared
		score_value_label.text = "%06d" % ScoreManager.current_score.score
		level_value_label.text = "%02d" % ScoreManager.current_score.level
