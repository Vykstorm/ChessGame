extends Control

onready var player = $AnimationPlayer


func create_new_game():
	# Create a new game (change to main scene)
	get_tree().change_scene_to(preload("res://Game.tscn"))
	

# Called when the node enters the scene tree for the first time.
func _ready():
	$FadeRect.visible = true
	player.play("FadeIn")

func _on_NewGame_button_down():
	# Create new game
	player.play("FadeOut")
	


func _on_Exit_button_down():
	get_tree().quit()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		# When fade out animation finished...
		# Create new game
		create_new_game()
