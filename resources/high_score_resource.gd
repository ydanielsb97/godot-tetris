extends Resource

class_name HighScoreResource

const SCORE_FILE: String = "user://classic_tetris.tres"

@export var lines_cleared: int = 0
@export var lines_simultaneously: Dictionary[String, int] = {
	"single": 0,
	"double": 0,
	"triple": 0,
	"tetris": 0
}
@export var score: int = 0
@export var level: int = 0
@export var start_time:float = Time.get_unix_time_from_system()
@export var end_time:float = start_time

func save_score(high_score: HighScoreResource) -> bool:
	if !high_score: high_score = load_high_score()
	
	var was_highscore = score >= high_score.score
	if was_highscore:
		ResourceSaver.save(self, SCORE_FILE)
	return was_highscore

static func load_high_score() -> HighScoreResource:
	if ResourceLoader.exists(SCORE_FILE):
		return load(SCORE_FILE)
	return HighScoreResource.new()
