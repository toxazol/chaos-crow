extends Node

# The player's score
var score: int = 0

# Signal for when the score changes
signal score_updated(new_score)

# Set score directly
func set_score(points: int):
	score = points
	score_updated.emit(score)
	
# Increase score
func add_score(points: int):
	score = max(0, score + points)  # Prevent negative scores
	score_updated.emit(score)  # Emit signal to update UI
	
# Reset score
func reset_score():
	score = 0
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
