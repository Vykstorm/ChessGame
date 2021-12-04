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
	# Also each is marked with the kind of piece it holds.
	var cells = null
	var num_rows = null 
	var num_cols = null
	
	func _init(n: int, m: int, pieces: Array):
		self.cells = []
		self.num_rows = n 
		self.num_cols = m
		for _i in range(0, n*m):
			self.cells.append(["", ""])
		for piece in pieces:
			self.set_cell(piece.board_position, piece.kind, piece.color)
		
	func set_cell(pos: Vector2, kind: String, color: String):
		# Set the cell (x,y) value
		self.cells[int(pos.x)-1+(int(pos.y)-1)*self.num_cols] = [kind, color]
		
	func _get_cell(pos: Vector2):
		return self.cells[int(pos.x)-1+(int(pos.y)-1)*self.num_cols]
		
	func get_color(pos: Vector2) -> String:
		# Get the color of the piece located at (x, y) cell or "" if it's empty.
		return self._get_cell(pos)[1]
		
	func get_piece_kind(pos: Vector2) -> String:
		# Get the type of piece located at (x, y) cell or "" if it's empty.
		return self._get_cell(pos)[0]
		
	func is_empty(pos: Vector2) -> bool:
		# Check if cell located at (x,y) is empty.
		return self._get_cell(pos)[0] == ""
		
	func in_bounds(pos: Vector2) -> bool:
		# Returns true if the given position is inside of the bound of this table.
		return pos.x >= 1 and pos.x <= self.num_cols and pos.y >= 1 and pos.y <= self.num_rows
		
		
	func get_cells_forward(pos: Vector2, max_steps) -> Array:
		# Get the cells moving forward from (x,y):  (x,y+1), (x,y+2), ...
		# Until we reached `max_steps` moves, went out of the table bounds or hit
		# an occupied cell.
		var moves = []
		pos += Vector2.DOWN
		var steps = 1
		while steps <= max_steps and self.in_bounds(pos) and self.is_empty(pos):
			moves.append(pos)
			pos += Vector2.DOWN
			steps += 1
		return moves
		
	func get_first_occupied_cell_moving_forward(pos: Vector2, color: String):
		# Get the first cell starting from the given position which is occupied with a piece
		# of the specified color. Returns null if no cells were hit moving forward or hit a piece
		# with opposite color.
		pos += Vector2.DOWN
		while self.in_bounds(pos) and self.is_empty(pos):
			pos += Vector2.DOWN
		if self.in_bounds(pos) and self.get_color(pos) == color:
			return pos
		return null
		
		
		
	func get_cells_backward(pos: Vector2, max_steps) -> Array:
		var moves = []
		pos += Vector2.UP
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and self.is_empty(pos):
			moves.append(pos)
			pos += Vector2.UP
			steps += 1
		return moves
		
	func get_first_occupied_cell_moving_backward(pos: Vector2, color: String):
			pos += Vector2.UP
			while self.in_bounds(pos) and self.is_empty(pos):
				pos += Vector2.UP
			if self.in_bounds(pos) and self.get_color(pos) == color:
				return pos
			return null
			

	func get_cells_left(pos: Vector2, max_steps) -> Array:
		var moves = []
		pos += Vector2.LEFT
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and self.is_empty(pos):
			moves.append(pos)
			pos += Vector2.LEFT
			steps += 1
		return moves
		

	func get_first_occupied_cell_moving_left(pos: Vector2, color: String):
			pos += Vector2.LEFT
			while self.in_bounds(pos) and self.is_empty(pos):
				pos += Vector2.LEFT
			if self.in_bounds(pos) and self.get_color(pos) == color:
				return pos
			return null
		

	func get_cells_right(pos: Vector2, max_steps) -> Array:
		var moves = []
		pos += Vector2.RIGHT
		var steps = 1
		
		while steps <= max_steps and self.in_bounds(pos) and self.is_empty(pos):
			moves.append(pos)
			pos += Vector2.RIGHT
			steps += 1
		return moves
		
		
	func get_first_occupied_cell_moving_right(pos: Vector2, color: String):
			pos += Vector2.RIGHT
			while self.in_bounds(pos) and self.is_empty(pos):
				pos += Vector2.RIGHT
			if self.in_bounds(pos) and self.get_color(pos) == color:
				return pos
			return null
	
	
	func duplicate() -> Table:
		return self

	func apply_move(move: Move) -> Table:
		# Returns a new table configuration as a result of applying the given movement
		return self.duplicate()
	
	
	
	
func create_table(pieces: Array) -> Table:
	# Create a 8x8 table marking the cells of the table where
	# the given pieces are located.
	var table = Table.new(8, 8, pieces)
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
		if table.in_bounds(target) and table.get_color(target) != piece.color:
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





func _is_check(table: Table, color: String) -> bool:
	return false


func get_valid_moves(pieces, prev_moves, piece):
	# Returns a list of all valid moves for the given piece.
	# Each valid move is represented as a position indicating the cell where the
	# piece can move.
	var table = create_table(pieces)
	var moves = []
	
	if piece.kind == "pawn": # Possible moves for a pawn
		moves += get_valid_pawn_moves(table, prev_moves, piece)
	if piece.kind == "knight": 
		moves += get_valid_knight_moves(table, pieces, piece)
	elif piece.kind == "rook":
		moves += get_valid_rook_moves(table, pieces, piece)
	
	var valid_moves = []
	for move in moves:
		var table_after_move = table.apply_move(move)
		if not _is_check(table_after_move, piece.color):
			valid_moves.append(move)
	return valid_moves
	
	

	
func is_check(pieces: Array, color: String) -> bool:
	# Returns true if the king of the given color is in check, false otherwise.
	return _is_check(create_table(pieces), color)
	
func is_check_mate(pieces, prev_moves, color) -> bool:
	# Returns true if the king of the given color is in check mate.
	# Precondition: King must be in check.
	# Find a move for any piece of the same color as the king such that applying
	# that move will make the king go out of the check mate.
	var table = create_table(pieces)
	for piece in pieces:
		if piece.color != color:
			continue
		var moves = get_valid_moves(pieces, prev_moves, piece)
		for move in moves:
			var table_after_move = table.apply_move(move)
			if not _is_check(table_after_move, color):
				return false
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

