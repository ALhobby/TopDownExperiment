extends Area2D
class_name Bullet

export (int) var speed = 40

onready var kill_timer = $KillTimer  # Get node KillTimer from bullet scene
var direction := Vector2.ZERO


func _ready():
	kill_timer.start()


func set_direction(input_direction : Vector2):
	"""
	Method that allows to set the direction of the bullet object
	"""
	self.direction = input_direction
	rotation += self.direction.angle()


func _physics_process(delta : float) -> void:
	"""
	Handles movement of the bullet
	"""
	if direction != Vector2.ZERO:
		var velocity = direction * speed
		global_position += velocity


func _on_KillTimer_timeout() -> void:
	"""Function that deletes the bullet after a while
	"""
	queue_free()


func _on_Bullet_body_entered(body : Node) -> void:
	""" 
	Perform actions when bullet hits someone.
	This method runs when Bullet enteres a PhysicsBody2D.
	"""
	if body.has_method("handle_hit"):
		body.handle_hit()
	# Delete bullet
	queue_free()

