extends WindowDialog

signal new_game
signal go_to_menu


func _on_NewGameButton_pressed():
	hide()
	$Sounds.play("Capture")
	emit_signal("new_game")
	
	


func _on_GoToMenuButton_pressed():
	hide()
	# Go back to the menu
	$Sounds.play("Capture")
	emit_signal("go_to_menu")


