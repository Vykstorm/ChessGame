extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_NewGame_button_down():
	# Create new game
	get_tree().change_scene_to(preload("res://Game.tscn"))


func _on_Exit_button_down():
	get_tree().quit()
