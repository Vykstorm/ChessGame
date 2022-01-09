extends Control


func get_game_files():
	# Returns a list of all game files sorted by date (the most recent first)
	return [ "user://match.pgn", "user://match3.pgn" ]

onready var game_files = get_game_files()
onready var current_game_file_index = 0

func get_current_game_file():
	return game_files[current_game_file_index]

func update_game_view():
	# Updates the view of the currently selected game.
	$Game.load_game(get_current_game_file())
	
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
	gameInstance.match_file_to_load = get_current_game_file()
	gameInstance.enable_fadein_animation = false
	
	# Switch to the game scene.
	root.remove_child(self)
	root.add_child(gameInstance)
	

func _ready():
	update_game_view()
	$PrevGame.disabled = false
	$NextGame.disabled = false

func _on_Game_board_clicked():
	play_current_selected_game()

func _on_NextGame_pressed():
	show_next_game()


func _on_PrevGame_pressed():
	show_prev_game()
