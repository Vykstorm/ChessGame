extends Node2D

export (int) var max_display_moves = 20
export (Color) var algebra_last_move_color = Color.blue
export (Color) var algebra_check_color = Color.orange
export (Color) var algebra_checkmate_color = Color.red


var game_id = null # ID of this game
var enable_fadein_animation: bool


signal piece_selected
signal piece_deselected
signal stalemate
signal checkmate
signal check
signal piece_moved
signal promoted
signal board_clicked

onready var board = $Board
onready var game = GameRules
onready var Piece = preload("res://Piece.tscn")
onready var promotion_dialog = $PromotionDialog
onready var white_trophies = $Decoratives/Trophies/White
onready var black_trophies = $Decoratives/Trophies/Black
onready var quality_advantage = $Decoratives/QualityAdvantage
onready var gameover_dialog = $GameOverDialog
onready var moves_display = $Decoratives/Moves
onready var animation_player = $AnimationPlayer
onready var fade_rect = $FadeRect
onready var sound_player = $Sounds

# Current piece being dragged by user
var current_piece_selected = null

# Current turn "white" or "black"
var current_turn = "white"

# A list of all possible moves for the currently selected piece by the user.
var current_piece_selected_possible_moves = null

# A list of all moves made
var moves = null


func populate_board():
	# This function creates all the initial pieces.
	for piece_info in game.get_initial_pieces():
		var piece = Piece.instance()
		piece.board_position = piece_info.board_position
		piece.color = piece_info.color
		piece.kind = piece_info.kind
		board.add_piece(piece)

func next_turn():
	# Invoked after current player moves a piece
	if current_turn == "white":
		current_turn = "black"
	else:
		current_turn = "white"
	

func evaluate_board_state():
	# Given the current state of the board, evaluate check / checkmates and stalemates.
	# Returns:
	# "checkmate" if king of the opposite color is in a checkmate situation
	# "check" if king of the oppositve color is in not in checkmate but in check.
	# "stalemate" returned when king is in a stalemate situation.
	# Otherwise, return null
	var pieces = board.get_pieces()
	if game.is_check(pieces, game.get_opposite_color(current_turn)):
		# Opposite king in check
		
		# Check mate?
		if game.is_check_mate(pieces, moves, game.get_opposite_color(current_turn)):
			return "checkmate"
		else:
			return "check"
	else:
		# Opposite not in check
		# Stale mate?
		if game.is_stale_mate(pieces, moves, game.get_opposite_color(current_turn)):
			return "stalemate"
	return null
	


func do_move(move):
	# Do the given piece movement (update the board and evaluate the checks, checkmate and stalemate situations)
	# Move piece
	moves.append(move)
	
	var is_capture: bool = board.get_piece_in_cell(move.to) != null
	
	# Move the piece.
	board.do_move(move)
	
	# If move is a promotion, ask the player the kind of piece to replace the pawn
	# Then wait for the user to select the promotion piece.
	if move is game.PromotionMove:
		promotion_dialog.show_popup(current_turn)
	else:
		# Otherwise its a normal move, evaluate the game's current state and change player's turn.
		var board_state = evaluate_board_state()
		emit_signal("piece_moved", current_piece_selected, move.to, is_capture, board_state)
		if board_state != null:
			if board_state == "check":
				emit_signal("check", current_turn)
			elif board_state == "checkmate":
				emit_signal("checkmate", current_turn)
			elif board_state == "stalemate":
				emit_signal("stalemate", current_turn)
		
		# Query check/ stale mate
		if board_state in ["checkmate", "stalemate"]:
			return
			
		# Change turn
		next_turn()
	
	


func update_trophies():
	var pieces = board.get_pieces()
	var white_trophies_count = game.get_pieces_removed_count(pieces, "black")
	white_trophies_count["pawn"] -= game.get_promoted_pieces_count(pieces, "black")
	var black_trophies_count = game.get_pieces_removed_count(pieces, "white")
	black_trophies_count["pawn"] -= game.get_promoted_pieces_count(pieces, "white")

	white_trophies.set_trophies(white_trophies_count)
	black_trophies.set_trophies(black_trophies_count)
	
	
func update_quality_advantage():
	var pieces = board.get_pieces()
	quality_advantage.set_value(game.get_player_quality(pieces, "white")-game.get_player_quality(pieces, "black"))


func update_moves_display(algebra_moves: Array):
	var text: String
	if len(algebra_moves) == 0:
		text = ""
	else:
		var last_move = len(algebra_moves)-1
		var first_move = int(max(0, last_move-max_display_moves+1))
		var first_round = first_move/2
		var last_round = last_move/2
		var colors = {
			"last_move": algebra_last_move_color,
			"check": algebra_check_color,
			"checkmate": algebra_checkmate_color
		}
		text = Pgn.format_algebra(algebra_moves, first_round, last_round, true, colors)
	
	moves_display.bbcode_text = text






func _on_piece_clicked(piece):
	# Called when a piece is clicked
	
	if piece.is_queued_for_deletion():
		# Death pieces are no longer clickable.
		return
		
	# Don't select anything if promotion dialog is popped up?
	if promotion_dialog.visible or gameover_dialog.visible:
		return
	
	# Any piece selected currently?
	if current_piece_selected != null:
		if piece == current_piece_selected:
			return
		# Deselect current selected piece
		emit_signal("piece_deselected", current_piece_selected)
		current_piece_selected = null
		current_piece_selected_possible_moves = null
	
	# Check if piece color matches the current player.
	if piece.color != current_turn:
		return
		
	# Check if piece has valid moves or not.
	var valid_moves = game.get_valid_moves(board.get_pieces(), moves, piece)
	if len(valid_moves) == 0:
		return
	current_piece_selected_possible_moves = valid_moves

	current_piece_selected = piece
	emit_signal("piece_selected", piece)



func _on_piece_selected(piece):
	# Highlight cells which are valid moves
	var cells_to_highlight = []
	for move in current_piece_selected_possible_moves:
		if move is game.CastlingMove:
			cells_to_highlight.append(move.get_king_target_pos())
		else:
			cells_to_highlight.append(move.to)
	board.highlight_cells(cells_to_highlight)

func _on_piece_deselected(piece):
	# Ungighlight cells
	board.reset_highlighted_cells()




func _on_board_cell_clicked(selected_cell):
	# Called when user clicks a cell
	emit_signal("board_clicked")

	# Is any piece selected?
	if current_piece_selected == null:
		return
	
	# Check if clicked cell is one of the possible moves of the currently selected piece
	for move in current_piece_selected_possible_moves:
		if move.to == selected_cell:
			do_move(move)
			break
	
	# Deselect current piece and do nothing more
	emit_signal("piece_deselected", current_piece_selected)
	current_piece_selected = null
	current_piece_selected_possible_moves = null




func new_game():
	# Reset internal variables
	moves = []
	current_piece_selected = null
	current_piece_selected_possible_moves = null
	current_turn = "white"
	
	# Clear board
	board.reset()
	
	# Initialize board.
	populate_board()
	
	# Initialize decoratives
	update_trophies()
	update_quality_advantage()
	update_moves_display([])
	
	
func save_game():
	# Called when game should be saved
	var algebra = Algebra.get_algebra_from_moves(moves)
		
	# Update move indicator.
	update_moves_display(algebra)
	
	# Export algebra notation to pgn file
	var headers = {
		"White": "Victor",
		"Black": "AI"
	}

	Pgn.export_algebra_to_pgn_file(algebra, GameDatabase.get_game_pgn_file(game_id), headers)


func load_game():
	# Load the game from the pgn file provided.
	
	# Initialize board
	new_game()
	# Load pgn file
	var pgn = Pgn.load_algebra_from_pgn_file(GameDatabase.get_game_pgn_file(game_id))
	var headers = pgn["headers"]
	# Apply moves
	moves = Algebra.get_moves_from_algebra(pgn["moves"])
	for move in moves:
		current_turn = game.get_opposite_color(current_turn)
		board.do_move(move)

	# Update decoratives
	update_moves_display(pgn["moves"])
	update_trophies()
	update_quality_advantage()



func do_moves(moves: Array):
	for move in moves:
		do_move(move)



func go_to_menu():
	# Loads the main menu
	queue_free()
	get_tree().change_scene_to(load("res://Menu.tscn"))
	
func fade_out_and_go_to_menu():
	# Plays a fade out animation and then go to the main menu
	fade_rect.visible = true
	fade_rect.color = Color(1, 1, 1, 1)
	animation_player.play("FadeOut")


func _on_checkmate(color):
	$GameOverDialog/VBoxContainer/Message.text = color + " wins!"
	$GameOverDialog.popup()
	
func _on_stalemate(_color):
	$GameOverDialog/VBoxContainer/Message.text = "Draw!"
	$GameOverDialog.popup()

func _on_check(color):
	# Highlight king which is in check
	for piece in board.get_pieces():
		if piece.kind == "king" and piece.color != color:
			piece.set_display_color("check")
			piece.update_picture()
			break

func _on_promoted(kind):
	print("Promoted to ", kind)
	sound_player.play("Move")
	update_quality_advantage()
	save_game()



func _on_Restart_button_down():
	new_game()


func _on_PromotionDialog_piece_selected(kind):
	# Change piece pawn with the selected piece
	var move = moves[-1]
	move.promotion = kind
	var piece = board.get_piece_in_cell(move.to)
	piece.kind = kind
	piece.update_picture()
	
	emit_signal("promoted", kind)
	
	# Re-evaluate board state
	evaluate_board_state()
	
	# Next turn!
	next_turn()
	


func _on_piece_moved(_piece, _move, is_capture, board_state):
	# Update trophies
	update_trophies()
	# Update quality advantages displays
	update_quality_advantage()
	# Play "move" sound
	if board_state != null:
		if board_state == "check":
			sound_player.play("Capture")
		elif board_state == "checkmate":
			sound_player.play("GameOver")
	else:
		sound_player.play("Move" if not is_capture else "Capture")
	
	# Reset king display color
	for piece in board.get_pieces():
		if piece.kind == "king" and piece.color == current_turn:
			piece.set_display_color("normal")
			piece.update_picture()
			break
	
	# Save game
	save_game()


func _on_GameOverDialog_new_game():
	# Called when user presses the "new game" button in the game over dialog.
	new_game()
	

func _on_GameOverDialog_go_to_menu():
	# Called when user presses "go to menu" button in the game over dialog.
	fade_out_and_go_to_menu()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		go_to_menu()


func _on_GoBackToMenuButton_pressed():
	fade_out_and_go_to_menu()


func _on_SurrenderButton_pressed():
	$SurrenderDialog.popup()

func _on_SurrenderDialog_confirmed():
	$GameOverDialog/VBoxContainer/Message.text = game.get_opposite_color(current_turn) + " wins!"
	$GameOverDialog.popup()


# Called when the node enters the scene tree for the first time.
func _ready():
	if enable_fadein_animation:
		fade_rect.visible = true
		animation_player.play("FadeIn")
	if game_id != null:
		load_game()







