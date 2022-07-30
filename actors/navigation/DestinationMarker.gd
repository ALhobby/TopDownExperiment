extends Area2D

class_name DestinationMarker

signal dest_marker_clicked(marker_held_bool)


var marker_held_bool : bool = false


func _on_Area2D_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("Click"):
		marker_held_bool = true
		emit_signal("dest_marker_clicked", marker_held_bool)
