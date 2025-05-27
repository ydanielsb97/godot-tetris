extends Control

@onready var lines_label: Label = $Top/Score/LinesLabel
@onready var top_value_label: Label = $RightTop/Score/VBoxContainer/Control2/TopValueLabel
@onready var score_value_label: Label = $RightTop/Score/VBoxContainer/Control/ScoreValueLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_tree() -> void:
	SignalHub.score_update.connect(on_score_update)

func on_score_update() -> void:
	lines_label.text = "LINES - %03d" % ScoreManager.current_score.lines_cleared
	top_value_label.text = "%06d" % ScoreManager.high_score.score
	score_value_label.text = "%06d" % ScoreManager.current_score.score
