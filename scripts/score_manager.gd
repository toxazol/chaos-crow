extends Node

# The player's score
var score: int = 0
var liveScore: int = 0
var settledScore: int = 0

# Signal for when the score changes
signal score_updated(new_score)

func settle_score(points: int):
	settledScore += points

# Set score directly
#func update_score(points: int):
	#score = settledScore + points
	#score_updated.emit(score)
	
# Increase score
func add_score(points: int):
	liveScore = max(0, liveScore + points)  # Prevent negative scores
	score = liveScore + settledScore
	score_updated.emit(score)  # Emit signal to update UI
	
# Reset score
func reset_score():
	score = 0
	settledScore = 0
	liveScore = 0
	score_updated.emit(score)
	
func get_high_score():
	var config = ConfigFile.new()
	var highscore = 0
	if config.load("user://config.cfg") == OK:
		highscore = config.get_value("stats", "highscore", 0)  # Default is 0
	if highscore < score: # set to current if current is bigger
		highscore = score
		# save if score > highscore
		config.set_value("stats", "highscore", highscore)
		config.save("user://config.cfg")  # Saves persistently
	reset_score()
	return highscore
