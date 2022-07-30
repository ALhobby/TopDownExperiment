extends Area2D


onready var owner_team = -1
onready var capturing_team = -1
onready var timer : Timer = $CaptureTimer
onready var sprite : Sprite = $Sprite

var player_color = Color( 0, 1, 0, 1 )
var enemy_color = Color( 1, 0, 0, 1 )

var players_in_area_count : int = 0
var enemies_in_area_count : int = 0

var majority_team_int : int = -1

func _on_ObjectivePoint_body_entered(body):
	"""Modify count variables
	"""
	if body.has_method("get_team"):
		if body.get_team() == 0:
			players_in_area_count += 1
		elif body.get_team() == 1:
			enemies_in_area_count +=1
	check_base_capturable()


func _on_ObjectivePoint_body_exited(body):
	"""Modify count variables
	"""
	if body.has_method("get_team"):
		if body.get_team() == 0:
			players_in_area_count -= 1
		elif body.get_team() == 1:
			enemies_in_area_count -=1
	check_base_capturable()


func check_base_capturable():
	majority_team_int = mayority_team()
	if majority_team_int == -1:
		return
	elif majority_team_int == owner_team:
		# Timer interrupted
		timer.stop()
	elif majority_team_int != owner_team:
		capturing_team = majority_team_int
		timer.start()


func mayority_team() -> int:
	if players_in_area_count > enemies_in_area_count:
		return 0  # Player
	elif players_in_area_count < enemies_in_area_count:
		return 1  # Enemy
	else:
		return -1 # Tie


func _on_CaptureTimer_timeout():
	owner_team = capturing_team
	match owner_team:
		0:
			sprite.modulate = player_color
		1:
			sprite.modulate = enemy_color
