extends TileMap


onready var pieces = $Pieces
onready var Piece = preload("res://Piece.tscn")


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
			
			
func add_piece(piece):
	pieces.add_child(piece)
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
	
func reset():
	# Reset board cell colors and remove all the pieces
	reset_cell_colors()
	clear_pieces()


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_cell_colors()
