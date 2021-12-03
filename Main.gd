extends Node2D

signal on_piece_clicked
signal on_piece_selected
signal on_piece_deselected

onready var board = $Board
onready var game = $Game



# Current piece located under the user's mouse
var current_piece_under_mouse = null

# Current piece being dragged by user
var current_piece_selected = null

# Current turn "white" or "black"
var current_turn = "white"


func populate_board():
	# This function creates all the initial pieces.
	for piece in game.get_initial_pieces():
		board.add_piece(piece)


func get_valid_moves(piece) -> Array:
	# Discard moves where target cell is occupied by another piece
	# of the same color.
	var valid_moves = []
	return valid_moves



func _on_piece_mouse_entered(piece):
	# Called when user pass the mouse over a piece
	current_piece_under_mouse = piece

func _on_piece_mouse_exited(piece):
	# Called when user pass the mouse goes away from the piece
	if current_piece_under_mouse == piece:
		current_piece_under_mouse = null

	

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add pieces to board
	populate_board()
	# Capture piece mouse enter/exit events
	for piece in board.get_pieces():
		piece.get_node("Area2D").connect("mouse_entered", self, "_on_piece_mouse_entered", [ piece ])
		piece.get_node("Area2D").connect("mouse_exited", self, "_on_piece_mouse_exited", [ piece ])

func _input(_event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and current_piece_under_mouse != null:
		# A piece is clicked
		emit_signal("on_piece_clicked", current_piece_under_mouse)
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and current_piece_under_mouse == null:
		if current_piece_selected != null:
			# If user clicks out of any piece bounds, deselect current
			# selected piece.
			emit_signal("on_piece_deselected", current_piece_selected)
			current_piece_selected = null

func on_piece_clicked(piece):
	# Called when a piece is clicked
	# Any piece selected currently?
	if current_piece_selected != null:
		if piece == current_piece_selected:
			return
		# Deselect current selected piece
		emit_signal("on_piece_deselected", current_piece_selected)
	
	# Check if piece color matches the current player.
	if piece.color != current_turn:
		return
		
	# Check if piece has valid moves or not.
	var valid_moves = get_valid_moves(piece)
	if len(valid_moves) == 0:
		return

	current_piece_selected = piece
	emit_signal("on_piece_selected", piece)



func _on_piece_selected(piece):
	# Get valid moves
	var valid_moves = get_valid_moves(piece)
	# Highlight cells which are valid moves
	board.highlight_cells(valid_moves)


func _on_piece_deselected(_piece):
	# Unhighlight all cells
	board.reset_highlighted_cells()
