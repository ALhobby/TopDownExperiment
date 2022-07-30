extends Node2D

# This script defines the movement behaviour of the non-player-controlled units

signal action_selected(action_id, speed_value)
signal request_destinaiton(Node)


var random = RandomNumberGenerator.new()
var speed : int = 0
var path = null
var destination = position

enum Action {
	MOVE = 0,
	DASH = 1,
	STAND_STILL = 2
}


func _ready():
	random.randomize()


func select_action() -> int:
	"""Select which action to perform.
	"""
	var selection = random.randi_range(0, 2)
	#selection = 2  # TODO : delete
	print("RANDOMLY SELECTED: ", selection)
	match selection:
		0:  # MOVE
			print("MOVE")
			speed = get_parent().base_speed
		1:  # DASH
			print("DASH")
			speed = get_parent().base_speed * 2
		2:  # STAND STILL
			print("STAND STILL")
			speed = 0
		
	emit_signal("action_selected", selection, speed)
	return selection


func get_path_to_destination(dest) -> PoolVector2Array:
	"""Path for the soldier to follow
	"""
	# Shortest path from position to destiantion
	path = get_node("/root/Main/Navigation2D").get_simple_path(get_parent().position, dest)
	return path


func generate_random_destination(max_value : int):
	return Vector2(random.randi_range(0,max_value), random.randi_range(0,max_value))


func request_destination_to_mapAI():
	"""Request update to 'destination' parameter of parent node.
	"""
	emit_signal("request_destinaiton", get_parent())  # Signal goes to MapAi through EnemySquad


func set_destination(new_dest):
	destination = new_dest
