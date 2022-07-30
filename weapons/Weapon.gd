extends Node2D
class_name Weapon

export (PackedScene) var Bullet

signal weapon_fired(bullet, location, direction)


onready var end_of_gun = $EndOfGun
onready var gun_direction = $GunDirection
onready var attack_cooldown = $AttackCooldown


func shoot():
	# Shoot only if: cooldown allows it, there is a bullet, and it's execution phase
	if attack_cooldown.is_stopped() and Bullet != null and get_node("/root/Main").get_turn_phase():
		var bullet_instance = Bullet.instance()  # Create instance of bullet
		var direction = (gun_direction.global_position - end_of_gun.global_position).normalized()
		emit_signal("weapon_fired", bullet_instance, end_of_gun.global_position, direction)
		attack_cooldown.start()
