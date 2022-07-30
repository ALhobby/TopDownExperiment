extends KinematicBody2D

# Player-controlled unit

signal player_died()

onready var stats = $Statistics
onready var weapon = $Weapon
onready var shooting_ai = $ShootingAI
onready var movement_sys = $MovementSystem
onready var collision_shape = $CollisionShape2D

# Coordinates of CollisionShape2D, used for RayCast checks
onready var cs_north = Vector2(collision_shape.position.x, -collision_shape.shape.radius)
onready var cs_east = Vector2(collision_shape.shape.radius, collision_shape.position.y)
onready var cs_south = Vector2(collision_shape.position.x, collision_shape.shape.radius)
onready var cs_west = Vector2(-collision_shape.shape.radius, -collision_shape.position.y)

onready var base_speed : int = stats.speed
onready var speed : int = base_speed
var path = PoolVector2Array()
var can_shoot : bool = true
var execution_phase : bool = false

################################################################################
# Functions
################################################################################
func _ready() -> void:
	shooting_ai.initialize_values(stats.team, weapon)
	weapon.connect("weapon_fired", self, "shoot")  # Call 'shoot()' when signal fired
	movement_sys.connect("movement_option_selected", self, "handle_action_pick")
	movement_sys.connect("new_path_calculated", self, "get_path")
	print("Player is ", self)


func _on_Player_input_event(_viewport, event, _shape_idx):
	"""Detect input events pertaining to Player
	"""
	if Input.is_action_just_pressed("Click"):
		# If no marker exists
		if movement_sys.destination_node.dest_marker == null:
			movement_sys.open_popup_menu()
		# Or marker exists but is not overlapping with the unit
		elif not movement_sys.destination_node.dest_marker.overlaps_body(self):
			movement_sys.open_popup_menu()


func shoot(bullet_instance, location : Vector2, direction : Vector2):
	"""
	Function that sends signal that the player has made a shot.
	Gets called when weapon.shoot() signals up through signal "weapon_fired".
	Emits "soldier_fired_bullet" signal for BulletManager to handle.
	"""
	GlobalSignals.emit_signal("bullet_fired", bullet_instance, location, direction)


func handle_hit():
	"""Method that allows the player to take damage.
	"""
	stats.health -= 50
	print("Player hit! Remaining health: ", stats.health)
	if stats.health <= 0:
		print(self, ": I am freed ")
		emit_signal("player_died")
		queue_free()


func handle_planning_phase_start():
	"""Make preparation before the planning phase begins
	""" 
	execution_phase = false


func handle_execution_phase_start():
	"""Make preparations before execution phase begins.
	"""
	# Clean up the line drawn by the movement system
	if movement_sys.line:
		movement_sys.line.queue_free()
	# If there is a destination marker, face towards it
	execution_phase = true
	if movement_sys.destination_node.dest_marker != null:
		look_at(movement_sys.destination_node.dest_marker.global_position)


func handle_action_pick(move_id : int, move_speed : int):
	"""Call the relevant setters in response to the chosen action.
	"""
	set_speed(move_speed)
	if move_id == 1:  # DASH
		set_can_shoot(false)
	else:
		set_can_shoot(true)


func set_speed(new_speed : int):
	"""Setter for the speed variable. Called when ActionSelect button is clicked.
	"""
	self.speed = new_speed


func set_can_shoot(new_bool : bool):
	self.can_shoot = new_bool


func set_path(new_path):
	path = new_path
	movement_sys.path = new_path


func get_path():
	path =  movement_sys.path
	return path


func get_team() -> int:
	return stats.team


################################################################################
# Physiscs process
################################################################################
func _physics_process(delta):

	#Planning phase
	if not execution_phase:  # If we are on the planning phase
		pass

	#Execution phase
	if execution_phase:  # If we are in the execution phase
		var distance_to_walk = speed * delta  # Walk distance for this frame,
		 #product of soldiers speed and the time elapsed from the previous frame
		
		# Move soldier along the path until he runs out of movement or path ends.
		while distance_to_walk > 0 and path.size() > 0: 
			var distance_to_next_point = get_global_position().distance_to(path[0])
			# Soldier doesn't have enough movement left to get to the next point.
			if distance_to_walk <= distance_to_next_point:
				global_position += get_global_position().direction_to(path[0]) * distance_to_walk
				# Unitary vector * distance
			else: # Soldier gets to the next point this 'tick'
				global_position = path[0]
				path.remove(0)  # Same as 'pop'?
			distance_to_walk -= distance_to_next_point  # Update the distance to walk
