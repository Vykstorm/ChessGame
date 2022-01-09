extends Control



func play_current_selected_game():
	# Play current selected game (changes the
	# scene)
	var tree: SceneTree = get_tree()
	var root: Node = tree.get_root()

	var gameScene = preload("res://Game.tscn")
	var gameInstance = gameScene.instance() 
	
	root.remove_child(self)
	gameInstance.match_file_to_load = "user://match.pgn"
	gameInstance.enable_fadein_animation = false
	root.add_child(gameInstance)
	


func _on_Game_board_clicked():
	play_current_selected_game()

func _ready():
	$Game.load_game("user://match.pgn")
