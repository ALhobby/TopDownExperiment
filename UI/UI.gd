extends Control


signal reset_camera()

#Variables
onready var curTurnText : Label = get_node("TurnText") # text showing our current turn
onready var timerText : Label = get_node("TimerText") # text showing remaining time on timer
onready var timer : Node = get_node("CountdownTimer") # Timer for the countdown
onready var gameManager : Node = get_node("/root/Main") # game manager object in order to access those functions and values
var seconds_elapsed = 0

################################################################################
#Functions
################################################################################
func _on_ExecuteButton_pressed():
	"""When the EXECUTE botton gets pressed.
	"""
	gameManager.execute_turn()
	timerText.text = str(gameManager.turnDuration) + " seconds remaining"
	timer.set_wait_time(1)
	timer.start()


func on_end_turn():
	"""Updates the UI text with the end of turn changes.
	Called when countdown is over"""
	curTurnText.text = "Turn: " + str(gameManager.curTurn)


func _on_CountdownTimer_timeout():
	"""Calculates countdown and updates UI text
	"""
	seconds_elapsed += 1
	var time_left = gameManager.turnDuration - seconds_elapsed
	if time_left == 0:
		timer.stop()
		timerText.text = ""
		seconds_elapsed = 0
	else:
		timerText.text = str(time_left) + " seconds remaining" # Replace with function body.


func _on_Reset_zoom_pressed():
	"""When the "Reset camera" button gets pressed, emit signal.
	The signal is connected in the Main node and calls a method in Camera2D 
	"""
	emit_signal("reset_camera")
