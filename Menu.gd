extends Control

onready var player = $AnimationPlayer
onready var sound_player = $Sounds

onready var tree: SceneTree = get_tree()
onready var root: Node = tree.get_root()



func create_new_game():
	# Create a new game (change to main scene)
	var game_id = GameDatabase.new_game()

	var gameScene = load("res://Game.tscn")
	var gameInstance = gameScene.instance()
	gameInstance.game_id = game_id
	gameInstance.enable_fadein_animation = true
	root.remove_child(self)
	root.add_child(gameInstance)
	queue_free()

func open_load_game_screen():
	get_tree().change_scene_to(load("res://LoadGame.tscn"))
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if len(GameDatabase.get_game_files()) == 0:
		# No games to load yet.!
		$Layout/Options/LoadGame.queue_free()
	$FadeRect.visible = true
	$FadeRect.color = Color.black
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
	elif anim_name == "FadeIn":
		pass


func _on_LoadGame_button_down():
	open_load_game_screen()


func _on_button_down():
	sound_player.play("Move")




