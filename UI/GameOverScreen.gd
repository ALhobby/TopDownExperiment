extends CanvasLayer

onready var title = get_node("PanelContainer/MarginContainer/Rows/Title")


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Main.tscn")


func _on_QuitButton_pressed():
	"""Exit game
	"""
	get_tree().quit()


func set_title(new_title):
	title.text = new_title
