extends Label

func _ready() -> void:
	ScoreManager.score_updated.connect(on_score_updated)

func on_score_updated(score: int) -> void:
	text = str(score)
