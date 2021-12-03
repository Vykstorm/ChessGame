extends TileMap


onready var pieces = $Pieces
onready var Piece = preload("res://Piece.tscn")
enum {A=1, B=2, C=3, D=4, E=5, F=6, G=7, H=8}



func hightlight_cell(cell):
	var y = 8-cell.y
	var x = cell.x-1
	set_cell(x, y, 2)

func highlight_cells(cells):
	# Hightlight the given cells
	for cell in cells:
		hightlight_cell(cell)
	
func reset_highlighted_cells():
	# Unhighlight all the cells
	reset_cell_colors()
	
func reset_cell_colors():
	for y in range(0, 8):
		for x in range(0, 8):
			set_cell(x, y, (1-x%2+y)%2 )
			
			
func add_piece(kind, color, x, y):
	var piece = Piece.instance()
	piece.board = self
	piece.board_position = Vector2(x, y)
	piece.color = color
	piece.kind = kind
	pieces.add_child(piece)
	return piece


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


func populate_board():
	# This function creates all the initial pieces.
	
	# Create white pawns.
	for x in range(1, 9):
		add_piece("pawn", "white", x, 2)
	
	# Create black pawns.
	for x in range(1, 9):
		add_piece("pawn", "black", x, 7)
		
	# Create rooks
	add_piece("rook", "white", A, 1)
	add_piece("rook", "white", H, 1)
	add_piece("rook", "black", A, 8)
	add_piece("rook", "black", H, 8)
	
	# Create knights
	add_piece("knight", "white", B, 1)
	add_piece("knight", "white", G, 1)
	add_piece("knight", "black", B, 8)
	add_piece("knight", "black", G, 8)
	
	# Create bishops
	add_piece("bishop", "white", C, 1)
	add_piece("bishop", "white", F, 1)
	add_piece("bishop", "black", C, 8)
	add_piece("bishop", "black", F, 8)

	# Create queens
	add_piece("queen", "white", D, 1)
	add_piece("queen", "black", E, 8)
	
	# Create kings
	add_piece("king", "white", E, 1)
	add_piece("king", "black", D, 8)


func reset_pieces():
	populate_board()
	
func reset():
	reset_cell_colors()
	reset_pieces()


# Called when the node enters the scene tree for the first time.
func _ready():
#	cell_size.x = (get_viewport_rect().size.x) / 8
#	cell_size.y = cell_size.x
	pass
