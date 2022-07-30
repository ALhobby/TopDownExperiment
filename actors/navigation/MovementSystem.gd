extends Node2D

# Main movement system script for player-controlled units.
# Gets Destination inforamation from the Destination node
# And determines move speed based on ActionSelect

signal movement_option_selected(move_option, corresponding_move_speed)
signal request_new_path(self_node, current_position, destination)
signal new_path_calculated()

onready var pupup_menu = $CanvasLayer/ActionSelect
onready var destination_node = $DestinationSelection

enum PopupIDs {
	MOVE = 0,
	DASH = 1,
	STAND_STILL = 2
}

onready var line : Line2D
var popup_menu_size = Vector2(100,20)
var speed : int = 0
var path = null

################################################################################
# Functions
################################################################################
func _ready() -> void:
	
	# Populate popup menu
	pupup_menu.add_item("Move", PopupIDs.MOVE)
	pupup_menu.add_item("Dash", PopupIDs.DASH)
	pupup_menu.add_item("Stand Still", PopupIDs.STAND_STILL)

	destination_node.connect("marker_placed", self, "request_path_to_destination")
	destination_node.connect("request_path_to_marker", self, "request_path_to_destination")


func open_popup_menu():
	pupup_menu.popup(Rect2(Vector2.ZERO, popup_menu_size))
	#pupup_menu.popup_centered_ratio(0.3)


func _on_ActionSelect_id_pressed(id):
	"""
	Select move type in the ActionSelect popup menu.
	TODO: modify fire rate accordingly.
	"""
	if id == PopupIDs.MOVE:
		speed = get_parent().base_speed
		destination_node.create_destination_marker()
	elif id == PopupIDs.DASH:
		speed = get_parent().base_speed * 2
		destination_node.create_destination_marker()
	elif id == PopupIDs.STAND_STILL:
		speed = 0
		# NOTE : no destination marker for this option
		destination_node.delete_dest_marker()
	emit_signal("movement_option_selected", id, speed)


func request_path_to_destination(destination, node_of_origin = self, origin=get_global_position()):
	"""Send signal upstream requesting calculation of shortest path to destination.
	This signal will cause the Navigation2D node to call the method 
	"set_path_to_destination(path)" with the newly calculated path.
	
	:destination: point in GLOBAL coordinates where we want to draw our path to
	"""
	emit_signal("request_new_path", node_of_origin, origin, destination)


func draw_path_to_destination(path) -> void:
	"""Function that draws the given path.
	"""
	if line:
		line.queue_free()
	line =  Line2D.new()
	line.default_color = Color(1,1,1,1)
	line.texture = load("res://assets/map/dotted-line.png")
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	var local_path : PoolVector2Array
	for point in path:
		local_path.append(to_local(point))
	line.points = local_path
	get_parent().add_child(line)


func set_path_to_destination(new_path):
	"""Path for the soldier to follow.
	Shortest path from position to destiantion.
	"""
	path = new_path
	emit_signal("new_path_calculated")


func delete_dest_marker():
	destination_node.delete_dest_marker()
