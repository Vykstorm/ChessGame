extends Node2D

signal piece_selected
signal piece_deselected
signal checkmated
signal piece_moved

onready var board = $Board
onready var game = $Game


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
	for piece in game.get_initial_pieces():
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
		cells_to_highlight.append(move.to)
	board.highlight_cells(cells_to_highlight)

func _on_piece_deselected(piece):
	# Ungighlight cells
	board.reset_highlighted_cells()



func _on_board_cell_clicked(selected_cell):
	# Called when user clicks a cell

	# Is any piece selected?
	if current_piece_selected == null:
		return
	
	# Check if clicked cell is one of the possible moves of the currently selected piece
	for move in current_piece_selected_possible_moves:
		if move.to == selected_cell:
			# Move piece
			moves.append(move)
			board.do_move(move)
			emit_signal("piece_moved", current_piece_selected, selected_cell)


			# Query check mate
			if game.is_check_mate(board.get_pieces()):
				emit_signal("checkmated", current_turn)
				return
			else:
				# Continue game 
				# Change turn
				next_turn()
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
