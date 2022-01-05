extends WindowDialog

signal new_game


func _on_NewGameButton_pressed():
	hide()
	emit_signal("new_game")
	


func _on_GoToMenuButton_pressed():
	hide()
	# Go back to the menu
	get_tree().change_scene_to(load("res://Menu.tscn"))


