extends Control

onready var game_files = GameDatabase.get_games()
onready var current_game_file_index = 0

func get_current_game():
	return game_files[current_game_file_index]

func update_game_view():
	# Updates the view of the currently selected game.
	$Game.game_id = get_current_game()
	$Game.load_game()
	
func show_next_game():
	current_game_file_index += 1
	current_game_file_index = current_game_file_index % len(game_files)
	update_game_view()
	
func show_prev_game():
	current_game_file_index -= 1
	if current_game_file_index == -1:
		current_game_file_index = len(game_files)-1
	update_game_view()


func play_current_selected_game():
	# Play current selected game (changes the
	# scene)
	var tree: SceneTree = get_tree()
	var root: Node = tree.get_root()
	
	# Load the game scene
	var gameScene = preload("res://Game.tscn")
	var gameInstance = gameScene.instance() 
	
	# Set game parameters.
	gameInstance.game_id = get_current_game()
	gameInstance.enable_fadein_animation = false
	
	# Switch to the game scene.
	root.remove_child(self)
	root.add_child(gameInstance)

func go_to_menu():
	# Loads the main menu
	queue_free()
	get_tree().change_scene_to(load("res://Menu.tscn"))

func _ready():
	# Disable internal game view GUI
	$Game.get_node("GUI").visible = false
	update_game_view()
	$PrevGame.disabled = false
	$NextGame.disabled = false
	
func _input(event):
	if event is InputEventScreenDrag:
		var v = event.relative.normalized()
		if v.dot(Vector2(1,0)) > 0:
			show_next_game()
		else:
			show_prev_game()

func _on_Game_board_clicked():
	play_current_selected_game()

func _on_NextGame_pressed():
	show_next_game()

func _on_PrevGame_pressed():
	show_prev_game()

func _on_GoBackToMenuButton_pressed():
	go_to_menu()
	
