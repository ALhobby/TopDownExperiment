extends KinematicBody2D

# AI controlled unit

signal enemy_died()

export (PackedScene) var Bullet
onready var shooting_ai = $ShootingAI
onready var stats = $Statistics
onready var weapon = $Weapon
onready var movement_ai = $MovementAI
onready var collision_shape = $CollisionShape2D

# Coordinates of CollisionShape2D, used for RayCast checks
onready var cs_north = Vector2(collision_shape.position.x, -collision_shape.shape.radius)
onready var cs_east = Vector2(collision_shape.shape.radius, collision_shape.position.y)
onready var cs_south = Vector2(collision_shape.position.x, collision_shape.shape.radius)
onready var cs_west = Vector2(-collision_shape.shape.radius, -collision_shape.position.y)


onready var base_speed = stats.speed
onready var speed = base_speed
var path : = PoolVector2Array()
var destination = position  # By default, destination is current position
var can_shoot : bool = true
var execution_phase : bool = false

################################################################################
# Methods
################################################################################
func _ready():
	add_to_group(get_parent().get_groups()[0])  # Add to same group as parent
	shooting_ai.initialize_values(stats.team, weapon)  # Give the ai access to the weapon
	movement_ai.connect("action_selected", self, "handle_action_pick")
	weapon.connect("weapon_fired", self, "shoot")
	


func shoot(bullet_instance, location : Vector2, direction : Vector2):
	"""
	Function that sends signal that the player has made a shot.
	Gets called when weapon.shoot() signals up through signal "weapon_fired".
	Emits "soldier_fired_bullet" signal for BulletManager to handle.
	"""
	GlobalSignals.emit_signal("bullet_fired", bullet_instance, location, direction)


func handle_hit():
	""" Method that allows the enemy to take damage
	"""
	stats.health -= 50
	print("Enemy hit! Remaining health: ", stats.health)
	if stats.health <= 0:
		print(self, ": I am freed")
		get_parent().remove_child(self)
		queue_free()
		emit_signal("enemy_died")


func handle_planning_phase_start():
	"""Make preparations before planning phase begins.
	"""
	execution_phase = false


func handle_execution_phase_start():
	"""Make preparations before execution phase begins.
	"""
	execution_phase = true
	movement_ai.select_action()
	#destination = movement_ai.generate_random_destination(1500)
	movement_ai.request_destination_to_mapAI()
	path = movement_ai.get_path_to_destination(destination)


func handle_action_pick(move_id : int, move_speed : int):
	"""Call the relevant setters in response to the chosen action.
	"""
	set_speed(move_speed)
	if move_id == 1:  # DASH
		set_can_shoot(false)
	else:
		set_can_shoot(true)


func set_destination(new_destination):
	destination = new_destination


func set_speed(new_speed):
	speed = new_speed


func set_can_shoot(new_bool : bool):
	self.can_shoot = new_bool


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
		var distance_to_walk = speed * delta  # Distance for this frame, product of soldiers speed and the time elapsed from the previous frame
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
