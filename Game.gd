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
const FORWARD=Vector2(0, 1)
const BACKWARD=Vector2(0, -1)

func get_opposite_color(color):
	if color == "white":
		return "black"
	return "white"



class Move:
	# Represents a piece move
	var from  # Position where the moving piece is located at
	var to 	  # Target position of the moving piece
	var piece_to_kill
	
	func _init(from, to, piece_to_kill=null):
		self.from = from
		self.to = to
		self.piece_to_kill = piece_to_kill



class Piece:
	var kind: String
	var color: String
	var board_position: Vector2
	
	func _init(kind: String, color: String, board_position: Vector2):
		self.kind = kind
		self.color = color
		self.board_position = board_position
	


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
			self.add_piece(piece)
		
	func add_piece(piece):
		# Add a new piece to the table.
		var pos = piece.board_position
		self.cells[int(pos.x)-1+(int(pos.y)-1)*self.num_cols] = [piece.kind, piece.color]
		
	func clear_cell(pos: Vector2):
		# Remove any piece in the given (x,y) cell if any. If there was a piece on it, also return
		# it, otherwise return null
		var k = int(pos.x)-1+(int(pos.y)-1)*self.num_cols
		var cell = self.cells[k]
		self.cells[k] = ["", ""]
		if cell[0] == "":
			return null
		return Piece.new(cell[0], cell[1], pos)
		
	func _get_cell(pos: Vector2):
		return self.cells[int(pos.x)-1+(int(pos.y)-1)*self.num_cols]
		
	func get_color(pos: Vector2) -> String:
		# Get the color of the piece located at (x, y) cell or "" if it's empty.
		return self._get_cell(pos)[1]
		
	func get_kind(pos: Vector2) -> String:
		# Get the type of piece located at (x, y) cell or "" if it's empty.
		return self._get_cell(pos)[0]
		
	func is_empty(pos: Vector2) -> bool:
		# Check if cell located at (x,y) is empty.
		return self._get_cell(pos)[0] == ""
		
	func get_piece(pos: Vector2):
		# Get the piece at the given position. An object with properties kind, color and
		# board_position. Returns null if no piece occupies the given position.
		var cell_info = self._get_cell(pos)
		if cell_info == null:
			return null
		var piece = Piece.new(cell_info[0], cell_info[1], pos)
		return piece
		
		
	func get_pieces() -> Array:
		# Get all the pieces on the board.
		var k = 0
		var pieces = []
		for cell in self.cells:
			var kind = cell[0]
			var color = cell[1]
			var pos = Vector2(k % self.num_cols + 1, int(k / self.num_cols) + 1)
			k += 1
			if kind != "":
				pieces.append(Piece.new(kind, color, pos))
		return pieces
		
		
	func in_bounds(pos: Vector2) -> bool:
		# Returns true if the given position is inside of the bound of this table.
		return pos.x >= 1 and pos.x <= self.num_cols and pos.y >= 1 and pos.y <= self.num_rows
		
		
	func get_free_cells_moving_to(pos: Vector2, max_steps, direction: Vector2):
		# Get all the free cells moving in the specified direction starting from an initial position
		# in the board ntil we reached `max_steps` moves or went out of the table bounds.
		var moves = []
		pos += direction
		var steps = 1
		while steps <= max_steps and self.in_bounds(pos) and self.is_empty(pos):
			moves.append(pos)
			pos += direction
			steps += 1
		return moves
		
	func get_first_occupied_cell_moving_to(pos: Vector2, color: String, direction: Vector2, max_steps=INF):
		# Get the first cell starting from the given position and moving in a specified direction
		# which is occupie by a piece of the specified color. Returns null if no cells were hit or hit a piece
		# with opposite color.
		pos += direction
		var steps = 1
		while steps < max_steps and self.in_bounds(pos) and self.is_empty(pos):
			pos += direction
			steps += 1
		if self.in_bounds(pos) and self.get_color(pos) == color:
			return pos
		return null
		
		
	func get_free_cells_moving_forward(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, FORWARD)

	func get_free_cells_moving_backward(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, BACKWARD)
	
	func get_free_cells_moving_left(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, LEFT)

	func get_free_cells_moving_right(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, RIGHT)
	
	func get_free_cells_moving_diag45(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, DIAG45)
		
	func get_free_cells_moving_diag135(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, DIAG135)
	
	func get_free_cells_moving_diag225(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, DIAG225)

	func get_free_cells_moving_diag315(pos: Vector2, max_steps) -> Array:
		return self.get_free_cells_moving_to(pos, max_steps, DIAG315)
		
	
	func get_first_occupied_cell_moving_forward(pos: Vector2, color: String, max_steps=INF):
		return self.get_first_occupied_cell_moving_to(pos, color, FORWARD, max_steps)

	func get_first_occupied_cell_moving_backward(pos: Vector2, color: String, max_steps=INF):
		return self.get_first_occupied_cell_moving_to(pos, color, BACKWARD, max_steps)
	
	func get_first_occupied_cell_moving_left(pos: Vector2, color: String, max_steps=INF):
		return self.get_first_occupied_cell_moving_to(pos, color, LEFT, max_steps)

	func get_first_occupied_cell_moving_right(pos: Vector2, color: String, max_steps=INF):
		return self.get_first_occupied_cell_moving_to(pos, color, RIGHT, max_steps)
		
		
	func get_first_occupied_cell_moving_diag45(pos: Vector2, color: String, max_steps=INF) -> Array:
		return self.get_first_occupied_cell_moving_to(pos, color, DIAG45, max_steps)
		
	func get_first_occupied_cell_moving_diag135(pos: Vector2, color: String, max_steps=INF) -> Array:
		return self.get_first_occupied_cell_moving_to(pos, color, DIAG135, max_steps)
	
	func get_first_occupied_cell_moving_diag225(pos: Vector2, color: String, max_steps=INF) -> Array:
		return self.get_first_occupied_cell_moving_to(pos, color, DIAG225, max_steps)

	func get_first_occupied_cell_moving_diag315(pos: Vector2, color: String, max_steps=INF) -> Array:
		return self.get_first_occupied_cell_moving_to(pos, color, DIAG315, max_steps)
		
	func get_free_cells_moving_horizontally(pos: Vector2, max_steps) -> Array:
		var directions = [FORWARD, BACKWARD, LEFT, RIGHT]
		var cells = []
		for direction in directions:
			cells += self.get_free_cells_moving_to(pos, max_steps, direction)
		return cells
	
	func get_free_cells_moving_diagonally(pos: Vector2, max_steps) -> Array:
		var directions = [DIAG45, DIAG135, DIAG225, DIAG315]
		var cells = []
		for direction in directions:
			cells += self.get_free_cells_moving_to(pos, max_steps, direction)
		return cells
	
	func get_free_cells_moving_any_direction(pos: Vector2, max_steps=INF) -> Array:
		var directions = [LEFT, RIGHT, FORWARD, BACKWARD, DIAG45, DIAG135, DIAG225, DIAG315]
		var cells = []
		for direction in directions:
			cells += self.get_free_cells_moving_to(pos, max_steps, direction)
		return cells
		
	func get_first_occupied_cells_moving_horizontally(pos: Vector2, color: String, max_steps=INF) -> Array:
		var directions = [FORWARD, BACKWARD, LEFT, RIGHT]
		var cells = []
		for direction in directions:
			var cell = self.get_first_occupied_cell_moving_to(pos, color, direction, max_steps)
			if cell != null:
				cells.append(cell)
		return cells
	
	func get_first_occupied_cells_moving_diagonally(pos: Vector2, color: String, max_steps=INF) -> Array:
		var directions = [DIAG45, DIAG135, DIAG225, DIAG315]
		var cells = []
		for direction in directions:
			var cell = self.get_first_occupied_cell_moving_to(pos, color, direction, max_steps)
			if cell != null:
				cells.append(cell)
		return cells
		
	func get_first_occupied_cells_moving_any_direction(pos: Vector2, color: String, max_steps=INF) -> Array:
		var directions = [LEFT, RIGHT, FORWARD, BACKWARD, DIAG45, DIAG135, DIAG225, DIAG315]
		var cells = []
		for direction in directions:
			var cell = self.get_first_occupied_cell_moving_to(pos, color, direction, max_steps)
			if cell != null:
				cells.append(cell)
		return cells

	
	func duplicate() -> Table:
		return Table.new(self.num_rows, self.num_cols, self.get_pieces())
			

	func apply_move(move: Move) -> Table:
		# Returns a new table configuration as a result of applying the given movement
		
		var table_after_move = self.duplicate()
		
		# Get attacking piece and remove it from its current cell position
		var attacking_piece = table_after_move.clear_cell(move.from)
		
		# Clear target cell (if any o  othther piece is in there)
		table_after_move.clear_cell(move.to)
		
		# Move piece to the target cell
		attacking_piece.board_position = move.to
		table_after_move.add_piece(attacking_piece)
		return table_after_move
	
	
	
func create_table(pieces: Array) -> Table:
	# Create a 8x8 table marking the cells of the table where
	# the given pieces are located.
	var table = Table.new(8, 8, pieces)
	return table





func get_initial_pieces():
	# Returns a list of items, one for each initial
	# piece that should be added to the board:
	# Each item is: (piece, color, x, y). (x,y) is the position
	# where piece is the label indicating the piece kind.
	# Finally, color should be white and black.
	# Create white pawns.
	var pieces = []
	for x in range(1, 9):
		pieces.append(["pawn", "white", x, 2])
#
	# Create black pawns.
	for x in range(1, 9):
		pieces.append(["pawn", "black", x, 7])

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
	
	var result = []
	for info in pieces:
		# TODO
		result.append(Piece.new(info[0], info[1], Vector2(info[2], info[3])))
	return result

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
	

func get_valid_pawn_moves(table: Table, prev_moves, piece) -> Array:
	# Get valid moves for a pawn
	var pos = piece.board_position
	var moves = []
	var diag_moves = []
	if piece.color == "white":
		for target in table.get_free_cells_moving_forward(pos, 2 if pos.y == 2 else 1):
			moves.append(Move.new(pos, target))
		
		# Pawn can move diagonally also!)
		var target = pos+DIAG135
		if table.get_color(target) == "black":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+LEFT, "black"):
			moves.append(Move.new(pos, target, pos+LEFT))
		target = pos+DIAG45
		if table.get_color(target) == "black":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+RIGHT, "black"):
			moves.append(Move.new(pos, target, pos+RIGHT))
	else:
		for target in table.get_free_cells_moving_backward(pos, 2 if pos.y == 7 else 1):
			moves.append(Move.new(pos, target))
			
		var target = pos+DIAG225
		if table.get_color(target) == "white":
			moves.append(Move.new(pos, target))
		elif en_passant_move_on(table, prev_moves, pos+LEFT, "white"):
			moves.append(Move.new(pos, target, pos+LEFT))
			
		target = pos+DIAG315
		if table.get_color(target) == "white":
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
	
	# Horizontal moves without collision
	for target in table.get_free_cells_moving_horizontally(pos, INF):
		moves.append(Move.new(pos, target))
	# Horizontal moves with collision
	for target in table.get_first_occupied_cells_moving_horizontally(pos, get_opposite_color(piece.color)):
		moves.append(Move.new(pos, target))
		
	return moves


func get_valid_bishop_moves(table: Table, piece):
	# Get all valid moves for a bishop.
	var pos = piece.board_position
	var moves = []
	# Diagonal moves without collision
	for target in table.get_free_cells_moving_diagonally(pos, INF):
		moves.append(Move.new(pos, target))
	# Diagonal moves with collision
	for target in table.get_first_occupied_cells_moving_diagonally(pos, get_opposite_color(piece.color), INF):
		moves.append(Move.new(pos, target))
	return moves

func get_valid_king_moves(table: Table, piece):
	# Get all valid moves for the king
	var pos = piece.board_position
	var moves = []
	# Horizontal moves without collision
	for target in table.get_free_cells_moving_any_direction(pos, 1):
		moves.append(Move.new(pos, target))
	# Horizontal moves with collision
	for target in table.get_first_occupied_cells_moving_any_direction(pos, get_opposite_color(piece.color), 1):
		moves.append(Move.new(pos, target))
	return moves
	
	
func get_valid_queen_moves(table: Table, piece):
	# Get all valid moves for the queen
	var pos = piece.board_position
	var moves = []
	# Horizontal moves without collision
	for target in table.get_free_cells_moving_any_direction(pos, INF):
		moves.append(Move.new(pos, target))
	# Horizontal moves with collision
	for target in table.get_first_occupied_cells_moving_any_direction(pos, get_opposite_color(piece.color), INF):
		moves.append(Move.new(pos, target))
	return moves



func get_valid_moves(pieces, prev_moves, piece, check_absolute_pins:bool=true):
	# Returns a list of all valid moves for the given piece given the current board configuration.
	# if `check_absolute_pins` is true (default), discard moves which threats the king with the same
	# color as the moving piece after the move (the moving piece is pinned)
	var table = create_table(pieces)
	var moves = []
	
	if piece.kind == "pawn": # Possible moves for a pawn
		moves += get_valid_pawn_moves(table, prev_moves, piece)
	if piece.kind == "knight": 
		moves += get_valid_knight_moves(table, pieces, piece)
	elif piece.kind == "rook":
		moves += get_valid_rook_moves(table, pieces, piece)
	elif piece.kind == "king":
		moves += get_valid_king_moves(table, piece)
	elif piece.kind == "bishop":
		moves += get_valid_bishop_moves(table, piece)
	elif piece.kind == "queen":
		moves += get_valid_queen_moves(table, piece)
	
	var valid_moves = []
	for move in moves:
		var table_after_move = table.apply_move(move)
		if not check_absolute_pins or not _is_check(table_after_move, piece.color):
			valid_moves.append(move)
	return valid_moves
	


func _is_check(table: Table, color: String) -> bool:
	var pieces = table.get_pieces()
	for piece in pieces:
		if piece.color == color:
			# Only pieces of the opposite color can check the king
			continue
		# Piece is checking the king if it has a valid move which targets
		# the cell's king
		var moves = get_valid_moves(pieces, [], piece, false)
		for move in moves:
			var target = move.to
			if table.get_kind(target) == "king":
				return true
	return false
	
	
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

