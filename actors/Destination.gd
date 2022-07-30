extends Node2D

# Script that handles the placing of the destination marker.

signal create_destination_marker(marker_scene)
signal marker_placed()
signal request_path_to_marker(destination, node, origin)

onready var dest_marker_scene = load("res://actors/navigation/DestinationMarker.tscn")

var marker_being_held =  false
var dest_marker = null
var line_to_marker = null


func create_destination_marker():
	"""Function that creates the dest_marker.
	It connects the newly created marker to the 'dest_marker_clicked' signal.
	"""
	emit_signal("create_destination_marker", dest_marker_scene)
	delete_dest_marker()
	dest_marker = dest_marker_scene.instance()
	dest_marker.connect("dest_marker_clicked", self, "set_marker_being_held_bool")
	dest_marker.set_position(Vector2.ZERO)  # Put on top of unit
	# Correct rotation so that marker doesn't rotate
	dest_marker.set_global_rotation(-get_parent().get_global_rotation())
	get_parent().add_child(dest_marker)  # Add as child to MovementSystem


func delete_dest_marker():
	"""Function that deletes the dest_marker.
	"""
	if dest_marker:
		dest_marker.queue_free()


func request_line_to_marker(marker_pos : Vector2):
	emit_signal("request_path_to_marker", dest_marker.global_position, self, to_global(get_parent().position))


##func generate_line_to_marker(marker_pos : Vector2) -> Line2D:
#	"""Create a Line2D object and apply a texture to it.
#	The line goes from the current position of the unit to the position of the
#	destination marker.
#	"""
#	remove_line_to_marker()  # Remove previous line if there was one
#	var line = Line2D.new()
#	line.z_index -= 1
#	line.texture = load("res://assets/map/dot_line.png")
#	line.texture_mode = Line2D.LINE_TEXTURE_TILE
#	var poolVectorArray : PoolVector2Array = []
#	poolVectorArray.append(Vector2.ZERO)  # Position of the soldier
#	poolVectorArray.append(marker_pos)
#	line.points = poolVectorArray
#	return line


func remove_line_to_marker():
	"""Removes previous Line2D if there was one.
	"""
	if line_to_marker:
		self.remove_child(line_to_marker)


func set_marker_being_held_bool(new_val : bool):
	"""Setter for the 'marker_being_held' boolean.
	Connected to the signal "dest_marker_clicked" emmited when marker is clicked.
	Emits signal "marker_placed" that in turn is connected to method
	"request_path_to_destination" in the MovementSystem node.
	"""
	if self.marker_being_held == true and new_val == false:
		# If the marker has been dropped
		emit_signal("marker_placed", dest_marker.global_position)

	self.marker_being_held = new_val


#func get_destination():
#	return destination


################################################################################
# Physics Process
################################################################################
func _physics_process(delta):
	# Planning phase
	if not get_parent().get_parent().execution_phase:  # If we are on the planning phase
		#print("PLANNING")
		if marker_being_held:
			# Movement of the marker itself
			dest_marker.global_position = lerp(dest_marker.global_position,
											   get_global_mouse_position(),
											   25*delta)
			request_line_to_marker(dest_marker.global_position)

	else:  # Execution phase
		pass


func _input(event):
	"""Listen for mouse release to know when we have dropped the marker
	"""
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.is_pressed():
			set_marker_being_held_bool(false)  # Marker has been released
