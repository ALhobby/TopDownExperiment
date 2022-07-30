extends Navigation2D

onready var line : Line2D #= $Line2D
var path = null

#func _ready():
#	line.texture = load("res://assets/map/dotted-line.png")
#	line.texture_mode = Line2D.LINE_TEXTURE_TILE


func calculate_shortest_path(origin_node : Node, input_position : Vector2, destination : Vector2):
	"""Calculate shortest path between two positions. This method is called as a
	response to the 'request_new_path' signal from the MovementSystem nodes of
	Player units.
	It calls the setter method 'set_path_to_destination' of those nodes with the
	new path as an argument.
	"""
	path =  self.get_simple_path(input_position, destination)
	if line:
		line.queue_free()
	line =  Line2D.new()
	line.default_color = Color(1,1,1,1)
	line.texture = load("res://assets/map/dotted-line.png")
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.points = path
	get_parent().add_child(line)

	# If the signal that is caussing this function to be called is coming from
	# a MovementSystem node
	if not origin_node.has_method("create_destination_marker"):
		origin_node.set_path_to_destination(path)
		origin_node.draw_path_to_destination(path)
	else:  # If it's instead being called from the Destination Node
		# Delete 'line' of MovementSystem. Used when DestMarker is re-picked up
		if origin_node.get_parent().line:
			origin_node.get_parent().line.queue_free()
