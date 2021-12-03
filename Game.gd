extends Node

enum {A=1, B=2, C=3, D=4, E=5, F=6, G=7, H=8}
const DIAG135 = Vector2(-1, 1)
const DIAG45 = Vector2(1, 1)
const DIAG225 = Vector2(-1, -1)
const DIAG315 = Vector2(1, -1)
const LEFT = Vector2.LEFT
const RIGHT = Vector2.RIGHT
const JUMP_UPLEFT = Vector2(-1, 2)
const JUMP_LEFTUP = Vector2(-2, 1)
const JUMP_UPRIGHT = Vector2(1, 2)
const JUMP_RIGHTUP = Vector2(2, 1)
const JUMP_DOWNLEFT = Vector2(-1, -2)
const JUMP_LEFTDOWN = Vector2(-2, -1)
const JUMP_DOWNRIGHT = Vector2(1, -2)
const JUMP_RIGHTDOWN = Vector2(2, -1)

onready var Piece = preload("res://Piece.tscn")



func get_opposite_color(color):
	if color == "white":
		return "black"
	return "white"

class Table:
	# Represents a table of cells. Cells can be marked with the strings
	# "black", "white" or "". To indicate if a black/white piece is located in the specified
	# cell, or it's empty. Table has size nxm
	var cells = null
	var num_rows = null 
	var num_cols = null
	
	func _init(n: int, m: int):
		self.cells = []
		self.num_rows = n 
		self.num_cols = m
		for _i in range(0, n*m):
			self.cells.append("")

		
	func set_cell(pos, value):
		# Set the cell (x,y) value
		self.cells[int(pos.x)-1+(int(pos.y)-1)*self.num_cols] = value
		
	func get_cell(pos):
		# Get the value of (x, y) cell
		return self.cells[int(pos.x)-1+(int(pos.y)-1)*self.num_cols]
		
	func in_bounds(pos):
		# Returns true if the given position is inside of the bound of this table.
		return pos.x >= 1 and pos.x <= self.num_cols and pos.y >= 1 and pos.y <= self.num_rows
		
		
	func get_cells_forward(pos, max_steps):
		# Get the cells moving forward from (x,y):  (x,y+1), (x,y+2), ...
		# Until we reached `max_steps` moves, went out of the table bounds or hit
		# an occupied cell.
		var moves = []
		pos += Vector2.DOWN
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and not self.get_cell(pos):
			moves.append(pos)
			pos += Vector2.DOWN
			steps += 1
		return moves
		
	func get_first_occupied_cell_moving_forward(pos, color):
		# Get the first cell starting from the given position which is occupied with a piece
		# of the specified color. Returns null if no cells were hit moving forward or hit a piece
		# with opposite color.
		pos += Vector2.DOWN
		while self.in_bounds(pos) and not self.get_cell(pos):
			pos += Vector2.DOWN
		if self.in_bounds(pos) and self.get_cell(pos) == color:
			return pos
		return null
		
		
		
	func get_cells_backward(pos, max_steps):
		var moves = []
		pos += Vector2.UP
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and not self.get_cell(pos):
			moves.append(pos)
			pos += Vector2.UP
			steps += 1
		return moves
		
	func get_first_occupied_cell_moving_backward(pos, color):
			pos += Vector2.UP
			while self.in_bounds(pos) and not self.get_cell(pos):
				pos += Vector2.UP
			if self.in_bounds(pos) and self.get_cell(pos) == color:
				return pos
			return null
			

	func get_cells_left(pos, max_steps):
		var moves = []
		pos += Vector2.LEFT
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and not self.get_cell(pos):
			moves.append(pos)
			pos += Vector2.LEFT
			steps += 1
		return moves
		

	func get_first_occupied_cell_moving_left(pos, color):
			pos += Vector2.LEFT
			while self.in_bounds(pos) and not self.get_cell(pos):
				pos += Vector2.LEFT
			if self.in_bounds(pos) and self.get_cell(pos) == color:
				return pos
			return null
		

	func get_cells_right(pos, max_steps):
		var moves = []
		pos += Vector2.RIGHT
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and not self.get_cell(pos):
			moves.append(pos)
			pos += Vector2.RIGHT
			steps += 1
		return moves
		
		
	func get_first_occupied_cell_moving_right(pos, color):
			pos += Vector2.RIGHT
			while self.in_bounds(pos) and not self.get_cell(pos):
				pos += Vector2.RIGHT
			if self.in_bounds(pos) and self.get_cell(pos) == color:
				return pos
			return null
	

	
	
	
func create_table(pieces):
	# Create a 8x8 table marking the cells of the table where
	# the given pieces are located.
	var table = Table.new(8, 8)
	for piece in pieces:
		table.set_cell(piece.board_position, piece.color)
	return table




class Move:
	# Represents a piece move
	var from  # Position where the moving piece is located at
	var to 	  # Target position of the moving piece
	var piece_to_kill
	
	func _init(from, to, piece_to_kill=null):
		self.from = from
		self.to = to
		self.piece_to_kill = piece_to_kill




func get_initial_pieces():
	# Returns a list of items, one for each initial
	# piece that should be added to the board:
	# Each item is: (piece, color, x, y). (x,y) is the position
	# where piece is the label indicating the piece kind.
	# Finally, color should be white and black.
	# Create white pawns.
	var pieces = []
#	for x in range(1, 9):
#		pieces.append(["pawn", "white", x, 2])
#
#	# Create black pawns.
#	for x in range(1, 9):
#		pieces.append(["pawn", "black", x, 7])
		
	# Create rooks
	pieces.append(["rook", "white", A, 1])
	pieces.append(["rook", "white", H, 1])
	pieces.append(["rook", "black", A, 8])
	pieces.append(["rook", "black", H, 8])
	
	# Create knights
	
	pieces.append(["knight", "white", B, 1])
	pieces.append(["knight", "white", G, 1])
	pieces.append(["knight", "black", B, 8])
	pieces.append(["knight", "black", G, 8])
	
	# Create bishops
	pieces.append(["bishop", "white", C, 1])
	pieces.append(["bishop", "white", F, 1])
	pieces.append(["bishop", "black", C, 8])
	pieces.append(["bishop", "black", F, 8])

	# Create queens
	pieces.append(["queen", "white", D, 1])
	pieces.append(["queen", "black", E, 8])
	
	# Create kings
	pieces.append(["king", "white", E, 1])
	pieces.append(["king", "black", D, 8])
	
	var instances = []
	for info in pieces:
		var instance = Piece.instance()
		instance.kind = info[0]
		instance.color = info[1]
		instance.board_position = Vector2(info[2], info[3])
		instances.append(instance)
	return instances

func en_passant_move_on(table, prev_moves, pos, color):
	# Check if there is a pawn with the specified color at the given position which moved the last turn 2 positions forward.
	var i = 0
	for prev_move in prev_moves:
		if color == "black":
			if prev_move.from.y == 7 and prev_move.from.x == pos.x:
				if prev_move.to.y == 5 and i == len(prev_moves)-1:
					return true
				return false
		else:
			if prev_move.from.y == 2 and prev_move.from.x == pos.x:
				if prev_move.to.y == 4 and i == len(prev_moves)-1:
					return true
				return false 
		i += 1
	return false
	

func get_valid_pawn_moves(table, prev_moves, piece) -> Array:
	# Get valid moves for a pawn
	var pos = piece.board_position
	var moves = []
	var diag_moves = []
	if piece.color == "white":
		for target in table.get_cells_forward(pos, 2 if pos.y == 2 else 1):
			moves.append(Move.new(pos, target))
		
		# Pawn can move diagonally also!)
		var target = pos+DIAG135
		if table.get_cell(target) == "black":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+LEFT, "black"):
			moves.append(Move.new(pos, target, pos+LEFT))
		target = pos+DIAG45
		if table.get_cell(target) == "black":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+RIGHT, "black"):
			moves.append(Move.new(pos, target, pos+RIGHT))
	else:
		for target in table.get_cells_backward(pos, 2 if pos.y == 7 else 1):
			moves.append(Move.new(pos, target))
			
		var target = pos+DIAG225
		if table.get_cell(target) == "white":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+LEFT, "white"):
			moves.append(Move.new(pos, target, pos+LEFT))
			
		target = pos+DIAG315
		if table.get_cell(target) == "white":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+RIGHT, "white"):
			moves.append(Move.new(pos, target, pos+RIGHT))
	return moves


func get_valid_knight_moves(table, pieces, piece):
	# Returns all possible moves for the given knight
	
	var jumps = []
	var pos = piece.board_position
	jumps.append(pos+JUMP_UPLEFT)
	jumps.append(pos+JUMP_LEFTUP)
	jumps.append(pos+JUMP_UPRIGHT)
	jumps.append(pos+JUMP_RIGHTUP)
	jumps.append(pos+JUMP_DOWNLEFT)
	jumps.append(pos+JUMP_LEFTDOWN)
	jumps.append(pos+JUMP_DOWNRIGHT)
	jumps.append(pos+JUMP_RIGHTDOWN)
	
	var moves = []
	for target in jumps:
		if table.in_bounds(target) and table.get_cell(target) != piece.color:
			moves.append(Move.new(pos, target))	
	return moves


func get_valid_rook_moves(table: Table, pieces, piece):
	var moves = []
	var pos = piece.board_position
	# Moves forward without collision
	for target in table.get_cells_forward(pos, INF):
		moves.append(Move.new(pos, target))
	# Move to an occupied cell moving forward
	var occupied_target = table.get_first_occupied_cell_moving_forward(pos, get_opposite_color(piece.color))
	if occupied_target != null:
		moves.append(Move.new(pos, occupied_target))
		
	# Moves forward without collision
	for target in table.get_cells_backward(pos, INF):
		moves.append(Move.new(pos, target))
	# Moves backward with collision
	occupied_target = table.get_first_occupied_cell_moving_backward(pos, get_opposite_color(piece.color))
	if occupied_target != null:
		moves.append(Move.new(pos, occupied_target))
		
	# Moves left/right without collision
	for target in table.get_cells_left(pos, INF):
		moves.append(Move.new(pos, target))
	for target in table.get_cells_right(pos, INF):
		moves.append(Move.new(pos, target))
	occupied_target = table.get_first_occupied_cell_moving_left(pos, get_opposite_color(piece.color))
	if occupied_target != null:
		moves.append(Move.new(pos, occupied_target))
	occupied_target = table.get_first_occupied_cell_moving_right(pos, get_opposite_color(piece.color))
	if occupied_target != null:
		moves.append(Move.new(pos, occupied_target))
	
	return moves




func get_valid_moves(pieces, prev_moves, piece):
	# Returns a list of all valid moves for the given piece.
	# Each valid move is represented as a position indicating the cell where the
	# piece can move.
	var table = create_table(pieces)
	
	if piece.kind == "pawn": # Possible moves for a pawn
		return get_valid_pawn_moves(table, prev_moves, piece)
	if piece.kind == "knight": 
		return get_valid_knight_moves(table, pieces, piece)
	elif piece.kind == "rook":
		return get_valid_rook_moves(table, pieces, piece)
	return []
	
func is_check_mate(_pieces) -> bool:
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

