extends Node2D

signal request_objective_marker_position(this_node)

var destination = null
var random = RandomNumberGenerator.new()


func _ready():
	random.randomize()


func give_destination(solicitior : Node):
	"""Give a destination to the unit that requested it.
	"""
	request_objective_marker_position()  # Request Objective Marker position to Main
	if solicitior.has_method("set_destination"):
		var random_offset = Vector2(random.randi_range(-200, 200), random.randi_range(-200, 200))
		solicitior.set_destination(destination+random_offset)
	else:
		print("ERROR : destination requested by ", solicitior, ", but lacks setter function.")


func request_objective_marker_position():
	"""Sends a signal asking Main node to update the 'destination' variable via
	the setter.
	"""
	emit_signal("request_objective_marker_position", self)  # Connected at Main node


func set_destination(new_destination):
	destination = new_destination
