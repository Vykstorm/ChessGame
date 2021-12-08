extends Node2D

signal piece_selected
signal piece_deselected
signal stalemate
signal checkmate
signal check
signal piece_moved
signal promoted

onready var board = $Board
onready var game = $Game
onready var Piece = preload("res://Piece.tscn")
onready var promotion_dialog = $PromotionDialog


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
	



func _on_piece_clicked(piece):
	# Called when a piece is clicked
	
	if piece.is_queued_for_deletion():
		# Death pieces are no longer clickable.
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


func evaluate_board_state():
	# Given the current state of the board, evaluate check / checkmates and stalemates.
	# Returns:
	# "checkmate" if king of the opposite color is in a checkmate situation
	# "check" if king of the oppositve color is in not in checkmate but in check.
	# "stalemate" returned when king is in a stalemate situation.
	# Otherwise, return true.
	var pieces = board.get_pieces()
	if game.is_check(pieces, game.get_opposite_color(current_turn)):
		# Opposite king in check
		
		# Check mate?
		if game.is_check_mate(pieces, moves, game.get_opposite_color(current_turn)):
			emit_signal("checkmate", current_turn)
			return "checkmate"
		else:
			emit_signal("check", current_turn)
			return "check"
	else:
		# Opposite not in check
		# Stale mate?
		if game.is_stale_mate(pieces, moves, game.get_opposite_color(current_turn)):
			emit_signal("stalemate", current_turn)
			return "stalemate"
	return true
	


func do_move(move):
	# Do the given piece movement (update the board and evaluate the checks, checkmate and stalemate situations)
	# Move piece
	moves.append(move)
	
	# If move is a promotion, ask the player the kind of piece to replace the pawn
	if move is game.PromotionMove:
		promotion_dialog.show_popup(current_turn)
	
	board.do_move(move)
	emit_signal("piece_moved", current_piece_selected, move.to)
	
	# Query check/ check mate
	if not (move is game.PromotionMove):
		var board_state = evaluate_board_state()
		if board_state in ["checkmate", "stalemate"]:
			return
	
	# If a pawn is promoted, wait for the user to select the promotion piece.
	# Otherwise, next turn.
	if not (move is game.PromotionMove):
		# Change turn
		next_turn()


func _on_board_cell_clicked(selected_cell):
	# Called when user clicks a cell

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




# Called when the node enters the scene tree for the first time.
func _ready():
	moves = []
	# Add pieces to board
	populate_board()
	
	connect("piece_selected", self, "_on_piece_selected")
	connect("piece_deselected", self, "_on_piece_deselected")

func _on_checkmate(_color):
	print("Check mate!")
	
func _on_stalemate(_color):
	print("Stale mate!")

func _on_check(_color):
	print("Check!")

func _on_promoted(kind):
	print("Promoted to ", kind)



func _on_Restart_button_down():
	board.reset()
	moves = []
	current_piece_selected = null
	current_piece_selected_possible_moves = null
	current_turn = "white"
	populate_board()


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
	
