extends TileMap

# Signal emitted when a cell is clicked.
signal cell_clicked
signal piece_clicked

onready var pieces = $Pieces
onready var Piece = preload("res://Piece.tscn")
onready var game = preload("res://Game.gd")
onready var highlighted_cells = $HighlightedCells

# Current piece located under the user's mouse
var current_piece_under_mouse = null



func hightlight_cell(cell):
	var y = 8-cell.y
	var x = cell.x-1
	# Only highlght cells not occupied by pieces
	var piece = get_piece_in_cell(cell)
	if piece == null:
		highlighted_cells.set_cell(x, y, 0)
	else:
		piece.set_display_color("threat")

func highlight_cells(cells):
	# Hightlight the given cells
	for cell in cells:
		hightlight_cell(cell)
		
func reset_highlighted_cells():
	# Unhighlight all the cells
	reset_cell_colors()
	for piece in get_pieces():
		piece.set_display_color("normal")
	
func reset_cell_colors():
	for y in range(0, 8):
		for x in range(0, 8):
			highlighted_cells.set_cell(x, y, -1 )
			
func paint_board_squares():
	for y in range(0, 8):
		for x in range(0, 8):
			set_cell(x, y, (1-x%2+y)%2)
			
			
func add_piece(piece):
	pieces.add_child(piece)
	# Capture piece mouse enter/exit events
	piece.get_node("Area2D").connect("mouse_entered", self, "_on_piece_mouse_entered", [ piece ])
	piece.get_node("Area2D").connect("mouse_exited", self, "_on_piece_mouse_exited", [ piece ])
	piece.update_position()


func get_piece_in_cell(cell):
	# Returns the piece which is in the specified cell or null
	# if any piece is in there.
	for piece in pieces.get_children():
		if piece.board_position == cell:
			return piece
	return null

func is_cell_occupied(cell):
	# Returns true if the given cell is occupied by any piece
	return get_piece_in_cell(cell) != null
	
	
func get_pieces():
	# Returns all the pieces of the board
	return pieces.get_children()


func clear_pieces():
	# Removes all the pieces
	for piece in pieces.get_children():
		piece.queue_free()
		

func do_move(move):
	# Do the given movement.
	
	if move is game.CastlingMove:
		# Move the king
		var king_to_move = get_piece_in_cell(move.get_king_source_pos())
		king_to_move.board_position = move.get_king_target_pos()
		king_to_move.update_position()
		
		# Move the rook
		var rook_to_move = get_piece_in_cell(move.get_rook_source_pos())
		rook_to_move.board_position = move.get_rook_target_pos()
		rook_to_move.update_position()
	
	elif move is game.PromotionMove:
		var pawn_to_move = get_piece_in_cell(move.from)
		var piece_to_remove = get_piece_in_cell(move.to)
		if piece_to_remove != null:
			piece_to_remove.queue_free()
		pawn_to_move.board_position = move.to
		pawn_to_move.update_position()
		
#		pawn_to_move.kind =  move.promotion
#		pawn_to_move.update_picture()
	else:
		var piece_to_move = get_piece_in_cell(move.from)
		assert(piece_to_move != null)
		var piece_to_remove = get_piece_in_cell(move.piece_to_kill) if move.piece_to_kill != null else get_piece_in_cell(move.to)
		if piece_to_remove != null:
			piece_to_remove.queue_free()
		piece_to_move.board_position = move.to
		piece_to_move.update_position()
	
func reset():
	# Reset board cell colors and remove all the pieces
	reset_cell_colors()
	clear_pieces()


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_cell_colors()
	paint_board_squares()


func _on_piece_mouse_entered(piece):
	# Called when user pass the mouse over a piece
	current_piece_under_mouse = piece

func _on_piece_mouse_exited(piece):
	# Called when user pass the mouse goes away from the piece
	if current_piece_under_mouse == piece:
		current_piece_under_mouse = null


func _input(event):
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(BUTTON_LEFT):
		var mouse_position = event.position
		var cell = world_to_map(to_local(mouse_position))
		var y = 8-cell.y
		var x = cell.x+1
		emit_signal("cell_clicked", Vector2(x, y))
		
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(BUTTON_LEFT) and current_piece_under_mouse != null:
		# A piece is clicked
		emit_signal("piece_clicked", current_piece_under_mouse)
