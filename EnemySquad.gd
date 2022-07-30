extends Node2D

onready var map_ai = $MapNavigationAI

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in self.get_children():
		if enemy.has_method("handle_hit"):  # Identify soldiers, no other nodes
			enemy.get_node("MovementAI").connect("request_destinaiton", map_ai, "give_destination")
