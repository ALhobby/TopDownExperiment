extends Node2D

################################################################################
# Variables
################################################################################
#const Player = preload("res://actors/Player.tscn")
const GameOverScreen = preload("res://UI/GameOverScreen.tscn") 

onready var ui : Node = get_node("UI/UI")
onready var player_squad : Node = get_node("PlayerSquad")
onready var enemy_squad : Node = get_node("EnemySquad")
onready var turn_timer : Node = get_node("TurnTimer")
onready var bullet_manager : Node = $BulletManager  # Get node BulletMAnager
onready var camera : Node = $Camera2D
onready var navigation2d_node : Node = $Navigation2D
onready var objective_point : Node = $ObjectivePoint


enum TurnPhase {
	PLANNING,
	EXECUTION
}

# Default phase
var current_turn_phase = TurnPhase.PLANNING setget set_turn_phase, get_turn_phase
var curTurn : int = 1  # Turn counter
var turnDuration : int = 3  # Turn duration in seconds


################################################################################
# Functions
################################################################################
func _ready ():
	"""
	Standard Godot '_ready()' function.
	Called when the node enters the scene tree for the first time.
	"""
	ui.on_end_turn()  # Updates UI turn value
	turn_timer.set_wait_time(turnDuration)

	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")

	ui.connect("reset_camera", camera, "reset_camera")

	for player in player_squad.get_children():
		# Connect the signal emited from each MovementSystem node of each Player:
		player.get_node("MovementSystem").connect("request_new_path", navigation2d_node, "calculate_shortest_path")
		player.connect("player_died", self, "check_game_over")

	for enemy in enemy_squad.get_children():
		if enemy.has_method("handle_hit"):
				enemy.connect("enemy_died", self, "check_game_over")
			
	enemy_squad.get_node("MapNavigationAI").connect("request_objective_marker_position", self, "give_objective_marker_position")


func execute_turn():
	"""
	Runs execution phase of the turn. It is called by the 'Execute' button.
	Starts turn timer. Sets 'execution_phase' to true.
	"""
	prepare_execution_start()
	turn_timer.start()
	set_turn_phase(1)


func end_turn ():
	"""
	Ends the current turn. Called when the Execution step is over.
	"""	
	curTurn += 1  # increase current turn
	set_turn_phase(0)
	ui.on_end_turn()  #Function that updates UI at end of turn
	prepare_planning_start()


func _on_TurnTimer_timeout():  # Function that ends the turn when timer stops
	"""
	Ends turn and stops turn timer. Called when Turn timer runs out.
	"""
	turn_timer.stop()
	end_turn()


func prepare_planning_start():
	"""Make preparations before planning phase begins.
	"""
	for player in get_node("PlayerSquad").get_children():
		if player.has_method("handle_planning_phase_start"):
			player.handle_planning_phase_start()
	for enemy in get_node("EnemySquad").get_children():
		if enemy.has_method("handle_planning_phase_start"):
			enemy.handle_planning_phase_start()


func prepare_execution_start():
	"""Make preparations before execution phase begins.
	"""
	for player in get_node("PlayerSquad").get_children():
		if player.has_method("handle_execution_phase_start"):
			player.handle_execution_phase_start()
	for enemy in get_node("EnemySquad").get_children():
		if enemy.has_method("handle_execution_phase_start"):
			enemy.handle_execution_phase_start()
	clean_before_execution()


func clean_before_execution():
	"""Delete all destination markers before we execute the turn.
	"""
	if navigation2d_node.line:
		navigation2d_node.line.queue_free()

	for player in get_node("PlayerSquad").get_children():
		player.get_node("MovementSystem").delete_dest_marker()
		player.get_node("MovementSystem").get_node("DestinationSelection").remove_line_to_marker()


func check_game_over():
	"""Check if we have any player-controlled untis left.
	This method gets called, via signal 'player_died', every time a player dies.
	"""
	# Little trick to avoid checking immediately
	var temp_timer = get_tree().create_timer(0.2)
	yield(temp_timer, "timeout")
	var game_over = GameOverScreen.instance()

	# Player lose
	if not player_squad.get_children():
		add_child(game_over)
		get_tree().paused = true

	# Player win
	elif enemy_squad.get_children().size() <= 1:
		add_child(game_over)
		game_over.set_title("Victory!")
		get_tree().paused = true


func give_objective_marker_position(solicitor : Node):
	"""Method that sets the destination of the EnemySquad Map AI.
	This function is called in response to the signal 'request_objective_marker_position'
	"""
	if solicitor.has_method("set_destination"):
		print("Objective MArker global_position: ", objective_point.global_position)
		solicitor.set_destination(objective_point.global_position)
	else:
		print("ERROR : Objective Marker position was requested to Main by ", solicitor, " but lacks necessary setter.")


func set_turn_phase(new_phase):
	"""Turn phase setter.
	"""
	current_turn_phase = new_phase


func get_turn_phase():
	"""Turn phase geter.
	"""
	return current_turn_phase


## Shooting AI debugging _draw
#onready var shooting_ai = $PlayerSquad/Player/ShootingAI
#func _draw():
#	var node_global_pos = shooting_ai.get_parent().position
#	draw_circle(node_global_pos, 35, Color( 0.97, 0.07, 1, 0.3 ))
#
#	if shooting_ai.target != null:
##		# As long as we have a target, ligth white circle around soldier
#		draw_circle(shooting_ai.get_parent().position, 40, Color( 0.97, 0.97, 1, 0.3 ))
#	if shooting_ai.target != null and shooting_ai.raycast_hit_position.size() >= 1:
#		for pos in shooting_ai.raycast_hit_position:
#			draw_circle(pos, 5, Color( 0.55, 0, 0, 1 ))
#			draw_line(node_global_pos, pos, Color( 0.55, 0, 0, 1 ))
#	if shooting_ai.enemy_points and shooting_ai.team == 0:
#		#draw_circle(shooting_ai.enemy_points[0], 70, Color(0,0,0,1))
#		for point in shooting_ai.enemy_points:
#			draw_circle(point, 7, Color( 0.55, 0.60, 0.2, 1 ))
#
#func _physics_process(delta):
#	update()
