extends Node2D


export (int) var speed = 150 setget set_speed
export (int) var health = 50 setget set_health
export (int) var team = 0  # Int values correspond to teams
# 0 : player
# 1 : enemy
# 2 : neutral?


func set_health(new_health : int):
	"""
	Because we named this function with 'setget', whenever anythin tries to set
	the "health" value externally, this function will get called. This is
	useful to make sure things are handled correctly and values make sense.
	"""
	health = clamp(new_health, 0, 300)

	# TODO : Emmit signal on health change?


func set_speed(new_speed : int):
	"""
	Because we named this function with 'setget', whenever anythin tries to set
	the "speed" value externally, this function will get called. This is
	useful to make sure things are handled correctly and values make sense.
	"""
	speed = clamp(new_speed, 0, 300)
