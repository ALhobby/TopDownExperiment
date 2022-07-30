extends Node2D

# Shooting AI

signal state_changed(new_state)

onready var target_detection_area = $TartgetDetectionArea
onready var textLabel: RichTextLabel = $DebugInfoText

enum State {
	NOT_SHOOTING,
	SHOOTING
}

var team : int = -1
var current_state = State.NOT_SHOOTING setget set_state  # Default state
var weapon : Weapon = null  # initialize 'weapon' variable
var target: KinematicBody2D = null

var raycast_hit_position = null
var enemy_points = null

# TODO : delete all of _ready

func _ready():
	textLabel.rect_size = Vector2(500,500)


func initialize_values(new_team : int, new_weapon : Weapon):
	"""
	Get values for variables coming from nodes at the same level as
	the shooting AI node.
	"""
	self.team = new_team
	self.weapon = new_weapon


func check_enemeies_inside_target_detection_area():
	"""Check if there are enemies of the opposing team inside of the target
	detecion area.
	Returns a list of enemies inside the area.
	"""
	var potential_targets = []
	for body_inside in target_detection_area.get_overlapping_bodies():
		if body_inside.has_method("get_team") and body_inside.get_team() != team:
				potential_targets.append(body_inside)
	return potential_targets


func line_of_vision_to(enemy_in_area : Node) -> bool:
	"""True if we have line of vision, False otherwise.
	"""
	# TODO : debugging
	enemy_points = [enemy_in_area.get_global_position(),
				   enemy_in_area.to_global(enemy_in_area.cs_north),
				   enemy_in_area.to_global(enemy_in_area.cs_east),
				   enemy_in_area.to_global(enemy_in_area.cs_south),
				   enemy_in_area.to_global(enemy_in_area.cs_west)]
	var space_state = get_world_2d().direct_space_state
	raycast_hit_position = []
	for point in enemy_points:
		var raycast_check_result_dict = space_state.intersect_ray(get_parent().position, point, [self, get_parent()], 1)
		if raycast_check_result_dict:
			if raycast_check_result_dict["collider"] == enemy_in_area:  # If raycast hits target
				raycast_hit_position.append(raycast_check_result_dict["position"])
				return true  # We have line of vision to 'enemy_in_area'
	return false  # We don't have line of vision


class MyCustomSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false

func pick_target():
	"""Pick a target to shoot at. Calls 'check_enemeies_inside_target_detection_area()'
	to get a list of candidates, and then chooses the closest of those for
	which there is line of vision.
	"""
	var min_dist = INF  # infinity
	var chosen_target = null

	var enemies_in_area = check_enemeies_inside_target_detection_area()
	if enemies_in_area:
		# For each rival team body in Area2D, sort by distance, check if we have
		# line of vision from closest to furthest.
		var distance_and_node_list = []
		for enemy in enemies_in_area:
			var dist = global_position.distance_to(enemy.global_position)
			distance_and_node_list.append([dist, enemy])
		distance_and_node_list.sort_custom(MyCustomSorter,"sort_ascending")
		# Extract enemies only to get list of enemies sorted by distance
		var sorted_enemies = []
		for dist_and_none in distance_and_node_list:
			sorted_enemies.append(dist_and_none[1])
		for potential_target in sorted_enemies:
			if line_of_vision_to(potential_target):  # LoV to target
				var dist = global_position.distance_to(potential_target.global_position)
				if min_dist > dist:
					chosen_target = potential_target
					min_dist = dist
				self.target = chosen_target
				return
			else:  # No LoV
				self.target = null


func _on_TartgetDetectionArea_body_exited(body : Node) -> void:
	"""
	If there are not targets available, go back to NOT_SHOOTING state.
	Called when anything exits Target Detection Area.
	"""
	# If the body that has dissapeared was our target, stop shooting.
	if target and body == target:
		target = null
		print("Unit ", get_parent(), "entered state: NOT SHOOTING")
		set_state(State.NOT_SHOOTING)


func set_state(new_state : int):
	"""
	Setter function for AI behaviour. 
	"""
	if new_state == current_state:
		return
	
	if current_state == State.NOT_SHOOTING and new_state == State.SHOOTING:
		if get_parent().can_shoot and target:
			current_state = new_state
			emit_signal("state_changed", current_state)
		else:  # State change not allowed by 'can_shoot' boolean
			#print("STATE CHANGE NOT ALLOWED")
			pass
	else:  # from SHOOTING to NOT_SHOOTING
		current_state = new_state
		emit_signal("state_changed", current_state)


func _draw():
	if current_state == 1:
		draw_circle(Vector2.ZERO, 30, Color( 0.86, 0.44, 0.58, 0.3))

func _physics_process(delta):
	update()
	if current_state == 0:
		self.textLabel.text = "I am " + str(get_parent()) + "\nState : NOT SHOOTING\n In Detection Area: " + str(check_enemeies_inside_target_detection_area()) + "\nTarget: " + str(target)
	elif current_state == 1:
		self.textLabel.text = "I am " + str(get_parent()) + "\nState : SHOOTING\n Target: " + str(target)
	textLabel.set_rotation(-get_parent().get_rotation())  # Correct rotation
	match current_state:
		State.NOT_SHOOTING:
			if get_parent().can_shoot:
				pick_target()
				if target:
					get_parent().look_at(target.global_position)
					set_state(State.SHOOTING)
			else:
				target = null
		State.SHOOTING:
			pick_target()
			if target and get_parent().can_shoot:
				get_parent().look_at(target.global_position)
				weapon.shoot()
			else:
				set_state(State.NOT_SHOOTING)
				target = null
