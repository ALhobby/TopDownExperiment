extends Camera2D

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var start_position  # Starting camera position
var start_zoom  # Starting zoom value


func _ready():
	screen_size = get_viewport_rect().size
	start_position = global_position
	start_zoom = self.get_zoom()


func reset_camera():
	print("Camera reset requested")
	self.global_position = start_position
	self.set_zoom(start_zoom)


func _process(delta):
	var velocity = Vector2()  # The player's movement vector.
	# Camera zoom
	if Input.is_action_pressed("ui_plus"):
		self.set_zoom(self.get_zoom()*0.95)
	if Input.is_action_pressed("ui_minus"):
		self.set_zoom(self.get_zoom()*1.05)
		
	# Camera movement
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x*2)
	position.y = clamp(position.y, 0, screen_size.y*2)
