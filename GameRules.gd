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
		

class PromotionMove:
	# Represents a pawn promotion move
	var from
	var to
	var promotion # The kind of piece that replaces the pawn
	
	func _init(from, to, promotion=null):
		self.from = from
		self.to = to
		self.promotion = promotion


class CastlingMove:
	var king_from: Vector2
	var king_to: Vector2
	var rook_from: Vector2
	var rook_to: Vector2
	var from: Vector2
	var to: Vector2
	# Represents a castling move
	func _init(color: String, kind: String):
		# color specifies the king's color which does the move and kind is either
		# 'kingside' or 'queenside' to indicate the type of castling.
		var king_pos
		var rook_pos: Vector2
		if color == "white":
			king_pos = Vector2(5, 1)
			rook_pos.y = 1
		else:
			king_pos = Vector2(5, 8)
			rook_pos.y = 8
		if kind == "kingside":
			rook_pos.x = 8
		else:
			rook_pos.x = 1
			
		# Get target rook & king positions
		var king_target_pos
		var rook_target_pos
		if kind == "kingside":
			king_target_pos = Vector2(king_pos.x + 2, king_pos.y)
			rook_target_pos = Vector2(rook_pos.x - 2, rook_pos.y)
		else:
			king_target_pos = Vector2(king_pos.x - 2, king_pos.y)
			rook_target_pos = Vector2(rook_pos.x + 3, rook_pos.y)
	
		self.king_from = king_pos
		self.king_to = king_target_pos
		self.rook_from = rook_pos
		self.rook_to = rook_target_pos
		self.from = king_pos
		self.to = king_target_pos
		
		
	func get_king_source_pos():
		return self.king_from
	
	func get_king_target_pos():
		return self.king_to
	
	func get_rook_source_pos():
		return self.rook_from
		
	func get_rook_target_pos():
		return self.rook_to
	
	func get_color():
		if get_king_source_pos().y == 1:
			return "white"
		return "black"




class Piece:
	var kind: String
	var color: String
	var board_position: Vector2
	var is_promotion: bool=false
	
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
		
	func get_pieces_of_color(color: String) -> Array:
		# Returns all the pieces in the board with the given color
		var pieces = []
		for piece in self.get_pieces():
			if piece.color == color:
				pieces.append(piece)
		return pieces
		
	func get_pieces_of_kind(kind: String) -> Array:
		# Returns all the pieces in the board of the type specified
		var pieces = []
		for piece in self.get_pieces():
			if piece.kind == kind:
				pieces.append(piece)
		return pieces
		
	func get_king(color: String) -> Piece:
		# Returns the king the given color
		for piece in self.get_pieces():
			if piece.kind == "king" and piece.color == color:
				return piece
		return null
		
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


	func get_movement_step(from: Vector2, to: Vector2) -> Vector2:
		# Given a source and target positions, returns a vector direction which represents
		# the small cell movement of a piece from source to target.
		var difference = to - from
		return Vector2(sign(difference.x), sign(difference.y))
		

	func get_first_occupied_cell_between(from: Vector2, to: Vector2):
		# Returns the first cell occupied by a piece between the given cells (excluding them). 
		# Precondition: The given cells must share the same diagonal/row or column, also they are
		# valid cells within the board.
		var direction = self.get_movement_step(from, to)
		var pos = from + direction
		while pos != to and self.is_empty(pos):
			pos += direction
		if pos != to:
			return pos
		return null
		
	
	func duplicate() -> Table:
		return Table.new(self.num_rows, self.num_cols, self.get_pieces())
			

	func apply_move(move) -> Table:
		# Returns a new table configuration as a result of applying the given movement
		if move is CastlingMove:
			var table_after_move = self.apply_move(Move.new(move.get_king_source_pos(), move.get_king_target_pos()))
			table_after_move.apply_move(Move.new(move.get_rook_source_pos(), move.get_rook_target_pos()))
			return table_after_move
		else:
			var table_after_move = self.duplicate()
			# Get attacking piece and remove it from its current cell position
			var moving_piece = table_after_move.clear_cell(move.from)
			
			# Clear target cell (if any other piece is in there)
			table_after_move.clear_cell(move.to)
			
			# Move piece to the target cell
			moving_piece.board_position = move.to
			table_after_move.add_piece(moving_piece)
			return table_after_move
	 
	
	
func create_table(pieces: Array) -> Table:
	# Create a 8x8 table marking the cells of the table where
	# the given pieces are located.
	var table = Table.new(8, 8, pieces)
	return table
	

func get_pieces_removed_count(pieces, color: String) -> Array:
	# Returns the number of pieces removed from the table of the given color
	var kinds = ["queen", "rook", "bishop", "knight", "pawn"]
	var counters = [1, 2, 2, 2, 8]
	
	for piece in pieces:
		if piece.kind == "king" or piece.color != color:
			continue
		counters[kinds.find(piece.kind)] -= 1
	
	var result = {}
	for i in range(0, len(counters)):
		result[kinds[i]] = counters[i]
	return result


func get_initial_pawns():
	var pieces = []
	# Create white pawns.
	for x in range(1, 9):
		pieces.append(Piece.new("pawn", "white", Vector2(x, 2)))

	# Create black pawns.
	for x in range(1, 9):
		pieces.append(Piece.new("pawn", "black", Vector2(x, 7)))
	return pieces
	
func get_initial_rooks():
	var pieces = [
		Piece.new("rook", "white", Vector2(A, 1)),
		Piece.new("rook", "white", Vector2(H, 1)),
		Piece.new("rook", "black", Vector2(A, 8)),
		Piece.new("rook", "black", Vector2(H, 8))
	]
	return pieces
	
func get_initial_knights():
	return [
		Piece.new("knight", "white", Vector2(B, 1)),
		Piece.new("knight", "white", Vector2(G, 1)),
		Piece.new("knight", "black", Vector2(B, 8)),
		Piece.new("knight", "black", Vector2(G, 8))
	]
	
func get_initial_bishops():
	return [
		Piece.new("bishop", "white", Vector2(C, 1)),
		Piece.new("bishop", "white", Vector2(F, 1)),
		Piece.new("bishop", "black", Vector2(C, 8)),
		Piece.new("bishop", "black", Vector2(F, 8))
	]

func get_initial_queens():
	return [
		Piece.new("queen", "white", Vector2(D, 1)),
		Piece.new("queen", "black", Vector2(D, 8))
	]
	
func get_initial_kings():
	return [
		Piece.new("king", "white", Vector2(E, 1)),
		Piece.new("king", "black", Vector2(E, 8))
	]
	

func get_initial_pieces():
	# Get all initial pieces that should be in a board
	
	var pieces = []
	# Create pawns
	pieces += get_initial_pawns()

	# Create rooks
	pieces += get_initial_rooks()

	# Create knights
	pieces += get_initial_knights()

	# Create bishops
	pieces += get_initial_bishops()

	# Create queens
	pieces += get_initial_queens()

	# Create kings
	pieces += get_initial_kings()
	
	return pieces
	

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
			if target.y == 8:
				moves.append(PromotionMove.new(pos, target))
			else:
				moves.append(Move.new(pos, target))
		
		# Pawn can move diagonally also!)
		var target = pos+DIAG135
		if table.get_color(target) == "black":
			if target.y == 8:
				moves.append(PromotionMove.new(pos, target))
			else:
				moves.append(Move.new(pos, target))
		elif pos.y == 5 and en_passant_move_on(table, prev_moves, pos+LEFT, "black"):
			moves.append(Move.new(pos, target, pos+LEFT))
		target = pos+DIAG45
		if table.get_color(target) == "black":
			if target.y == 8:
				moves.append(PromotionMove.new(pos, target))
			else:
				moves.append(Move.new(pos, target))
		elif pos.y == 5 and en_passant_move_on(table, prev_moves, pos+RIGHT, "black"):
			moves.append(Move.new(pos, target, pos+RIGHT))
	else: # Black pawns
		for target in table.get_free_cells_moving_backward(pos, 2 if pos.y == 7 else 1):
			if target.y == 1:
				moves.append(PromotionMove.new(pos, target))
			else:
				moves.append(Move.new(pos, target))
			
		var target = pos+DIAG225
		if table.get_color(target) == "white":
			if target.y == 1:
				moves.append(PromotionMove.new(pos, target))
			else:
				moves.append(Move.new(pos, target))
		elif pos.y == 4 and en_passant_move_on(table, prev_moves, pos+LEFT, "white"):
			moves.append(Move.new(pos, target, pos+LEFT))
			
		target = pos+DIAG315
		if table.get_color(target) == "white":
			if target.y == 1:
				moves.append(PromotionMove.new(pos, target))
			else:
				moves.append(Move.new(pos, target))
			
		elif pos.y == 4 and en_passant_move_on(table, prev_moves, pos+RIGHT, "white"):
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

func get_valid_king_moves(table: Table, prev_moves, piece):
	# Get all valid moves for the king
	var pos = piece.board_position
	var moves = []
	# Horizontal moves without collision
	for target in table.get_free_cells_moving_any_direction(pos, 1):
		moves.append(Move.new(pos, target))
	# Horizontal moves with collision
	for target in table.get_first_occupied_cells_moving_any_direction(pos, get_opposite_color(piece.color), 1):
		moves.append(Move.new(pos, target))
	# Castling
	moves += get_valid_castling_moves(table, prev_moves, piece.color)
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
	
	
func piece_at_cell_not_moved_yet(prev_moves: Array, cell: Vector2):
	for move in prev_moves:
		if move.from == cell:
			return false
	return true
	
	
	
func get_valid_castling_moves(table: Table, prev_moves, color: String) -> Array:
	# Is king on check?
	if _is_check(table, color):
		return []
	
	# There was any castling move already?
	for move in prev_moves:
		if move is CastlingMove and color == move.get_color():
			return []
	
	# No castling moves done yet?
	# The king moved a cell already?
	var king_initial_pos
	if color == "white":
		king_initial_pos = Vector2(5, 1)
	else:
		king_initial_pos = Vector2(5, 8)
	if not piece_at_cell_not_moved_yet(prev_moves, king_initial_pos):
		return []
	
	# kingside rook moved already?
	var kingside_rook_initial_pos: Vector2
	var queenside_rook_initial_pos: Vector2
	kingside_rook_initial_pos.x = 8
	kingside_rook_initial_pos.y = 1 if color == "white" else 8
	queenside_rook_initial_pos.x = 1
	queenside_rook_initial_pos.y = kingside_rook_initial_pos.y
	
	var moves = []
	if table.get_kind(kingside_rook_initial_pos) == "rook" and piece_at_cell_not_moved_yet(prev_moves, kingside_rook_initial_pos):
		moves.append(CastlingMove.new(color, "kingside"))
	if table.get_kind(queenside_rook_initial_pos) == "rook" and piece_at_cell_not_moved_yet(prev_moves, queenside_rook_initial_pos):
		moves.append(CastlingMove.new(color, "queenside"))
		
	# castling cannot be done if king is in check after the move or would be in check if king is placed in any cell
	# between it's current and final positions.
	var valid_moves = []
	for castling_move in moves:
		var king_target_pos = castling_move.get_king_target_pos()
		var rook_source_pos = castling_move.get_rook_source_pos()
		var direction = castling_move.get_king_target_pos() - king_initial_pos
		direction.x = sign(direction.x)
		
		# Are there any pieces between rook and king?
		if table.get_first_occupied_cell_between(king_initial_pos, rook_source_pos) != null:
			continue
		
		
		var pos: Vector2 = king_initial_pos
		var table_after_move = table.apply_move(Move.new(pos, pos+direction))
		pos += direction
		while pos != castling_move.get_king_target_pos() and not _is_check(table_after_move, color):
			table_after_move = table_after_move.apply_move(Move.new(pos, pos+direction))
			pos += direction
		
		if _is_check(table_after_move, color):
			continue
		# Castling can be done!
		valid_moves.append(castling_move)
		
	
	return valid_moves


	

func placed_in_same_row_or_column(piece_a, piece_b) -> bool:
	# Check if two pieces are located in the same row/column
	var difference = piece_a.board_position - piece_b.board_position
	var diffx = abs(int(difference.x))
	var diffy = abs(int(difference.y))
	return diffx == 0 or diffy == 0
	
func placed_in_same_diagonal(piece_a, piece_b) -> bool:
	# Check if two pieces are located in the same diagoal.
	var difference = piece_a.board_position - piece_b.board_position
	var diffx = abs(int(difference.x))
	var diffy = abs(int(difference.y))
	return diffx == diffy
	

func is_pinned(table: Table, piece) -> bool:
	# Check if the given piece is absolutely pinned. It is pinned if it cannot move without exposing its
	# king to a check.
	
	# A piece cannot be absolutely pinned if it's not placed in the same row/column or diagonal as the king
	var king = table.get_king(piece.color)
	if not placed_in_same_diagonal(king, piece) and not placed_in_same_row_or_column(king, piece):
		return false
	
	# Search another piece pinning the given piece.
	var direction = table.get_movement_step(king.board_position, piece.board_position)
	var cell = piece.board_position + direction
	while table.in_bounds(cell) and table.is_empty(cell):
		cell += direction
	if table.in_bounds(cell):
		# We found a piece sharing a diagonal/row or column with the king and the piece.
		var pinning_piece = table.get_piece(cell)
		if pinning_piece.color == piece.color:
			return false
		# And is an enemy piece...
		
		# If we are in the same row/column, only rooks & queens can be the pinning piece.
		if int(direction.x) == 0 or int(direction.y) == 0:
			return pinning_piece.kind in ["queen", "rook"]
		# If we are in the same diagonal, only queens and bishops can be the pinning piece...
		return pinning_piece.kind in ["queen", "bishop"]
		
	else:
		return false
	
	# Check if the given piece and its king are in a common row / column or diagonal.
	return false


func get_valid_moves(pieces, prev_moves, piece, check_pins:bool=true):
	# Returns a list of all valid moves for the given piece given the current board configuration.
	# if `check_pins` is true (default), discard moves which threats the king with the same
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
		moves += get_valid_king_moves(table, prev_moves, piece)
	elif piece.kind == "bishop":
		moves += get_valid_bishop_moves(table, piece)
	elif piece.kind == "queen":
		moves += get_valid_queen_moves(table, piece)
	
	var valid_moves = []
	for move in moves:
		# If the moving piece is absolutely pinned it's an invalid move...
#		if piece.kind != "king":
#			if check_pins and is_pinned(table, piece):
#				continue

		# The piece cannot do a move which leaves it's king threatened.
		var table_after_move = table.apply_move(move)
		if _is_check(table_after_move, piece.color):
			continue
		valid_moves.append(move)
	return valid_moves


func is_piece_being_threatened_by_knight(piece, knight) -> bool:
	var pos = piece.board_position
	var attacker_pos = knight.board_position
	var diff = attacker_pos - pos
	for jump in [
		JUMP_DOWNLEFT, JUMP_DOWNRIGHT, JUMP_LEFTDOWN, JUMP_LEFTUP,
		JUMP_RIGHTDOWN, JUMP_RIGHTUP, JUMP_UPLEFT, JUMP_UPRIGHT]:
		if diff == jump:
			return true
	return false

func is_piece_being_threatened_by_pawn(piece, pawn) -> bool:
	var attacker_pos = pawn.board_position
	var target_cells
	if pawn.color == "white":
		target_cells = [
			attacker_pos+DIAG45,
			attacker_pos+DIAG135
		]
	else:
		target_cells = [
			attacker_pos-DIAG45,
			attacker_pos-DIAG135
		]
	for target_cell in target_cells:
		if target_cell == piece.board_position:
			return true
	return false
	
func is_piece_being_threatened_by_rook(table: Table, piece, rook) -> bool:
	# Rook and piece on the same row or column?
	if not placed_in_same_row_or_column(piece, rook):
		return false
	# Check if there is not another piece between the attacker and the target piece.
	return table.get_first_occupied_cell_between(piece.board_position, rook.board_position) == null

func is_piece_being_threatened_by_queen(table: Table, piece, queen) -> bool:
	# Queen and piece on the same row, column or diagonal?
	if not placed_in_same_row_or_column(piece, queen) and not placed_in_same_diagonal(piece, queen):
		return false
	# Check if there is not another piece between the attacker and the target piece.
	return table.get_first_occupied_cell_between(piece.board_position, queen.board_position) == null


func is_piece_being_threatened_by_bishop(table: Table, piece, bishop) -> bool:
	# Bishop and piece on the same diagonal?
	if not placed_in_same_diagonal(piece, bishop):
		return false
	# Check if there is not another piece between the attacker and the target piece.
	return table.get_first_occupied_cell_between(piece.board_position, bishop.board_position) == null


func is_piece_being_threatened_by_king(piece, king) -> bool:
	var diff = piece.board_position - king.board_position
	return int(abs(diff.x)) <= 1 and int(abs(diff.y)) <= 1

	

func is_piece_being_theatened(table: Table, piece, attacker) -> bool:
	# Returns true if the given piece is being threatened by another piece, assuming both have
	# different colors.
	
	if attacker.kind == "knight":
		return is_piece_being_threatened_by_knight(piece, attacker)
		
	elif attacker.kind == "pawn":
		return is_piece_being_threatened_by_pawn(piece, attacker)

	elif attacker.kind == "rook":
		return is_piece_being_threatened_by_rook(table, piece, attacker)
		
	elif attacker.kind == "bishop":
		return is_piece_being_threatened_by_bishop(table, piece, attacker)
		
	elif attacker.kind == "queen":
		return is_piece_being_threatened_by_queen(table, piece, attacker)
	
	elif attacker.kind == "king":
		return is_piece_being_threatened_by_king(piece, attacker)
	return false
	


func _is_check(table: Table, color: String) -> bool:
	var pieces = table.get_pieces()
	var king = table.get_king(color)
	for piece in pieces:
		if piece.color == color:
			# Only pieces of the opposite color can check the king
			continue
		# Piece is checking the king if it has a valid move which targets
		# the cell's king
		if is_piece_being_theatened(table, king, piece):
			return true
	return false
	
	
func is_check(pieces: Array, color: String) -> bool:
	# Returns true if the king of the given color is in check, false otherwise.
	return _is_check(create_table(pieces), color)
	

func _is_check_mate(table: Table, prev_moves, color) -> bool:
	var pieces = table.get_pieces()
	for piece in pieces:
		if piece.color != color:
			continue
		var moves = get_valid_moves(pieces, prev_moves, piece)
		for move in moves:
			var table_after_move = table.apply_move(move)
			if not _is_check(table_after_move, color):
				return false
	return true
	
func is_check_mate(pieces, prev_moves, color) -> bool:
	# Returns true if the king of the given color is in check mate.
	# Precondition: King must be in check.
	# Find a move for any piece of the same color as the king such that applying
	# that move will make the king go out of the check mate.
	var table = create_table(pieces)
	return _is_check_mate(table, prev_moves, color)

	

func is_stale_mate(pieces, prev_moves, color) -> bool:
	# Returns true in case of stalemate: The king of the given color can't move to any
	# other cell nor any other piece of the same color can't move.
	# Precondition: King of the given color is not in check.
	var table = create_table(pieces)
	for piece in table.get_pieces_of_color(color):
		if len(get_valid_moves(pieces, prev_moves, piece)) > 0:
			return false 
	return true
	
	
	
func count_promotion_moves(moves, color) -> int:
	# Counts the number of promotion moves made by the player with the specified color
	var count = 0
	for i in range(0 if color == "white" else 1,len(moves),2):
		var move = moves[i]
		if move is PromotionMove:
			count += 1
	return count 
	
func get_promoted_pieces_count(pieces: Array, color: String) -> int:
	# Returns the number of pieces currently in the board which were pawns before promoting themselves with
	# the specified color
	var count = 0
	for piece in pieces:
		if piece.color == color and piece.is_promotion:
			count += 1
	return count
	
func get_player_quality(pieces: Array, color: String) -> int:
	# Returns the sum of the quality of the remaining pieces with the given color.
	var quality = 0
	for piece in pieces:
		if piece.color != color:
			continue
		var kind = piece.kind
		if kind == "pawn":
			quality += 1
		elif kind in ["bishop", "knight"]:
			quality += 3
		elif kind == "rook":
			quality += 5
		elif kind == "queen":
			quality += 9
	return quality
	
func count_pieces_on_column_of_kind(table: Table, kind: String, color: String, column) -> int:
	# Count the number of pieces of the kind specified in the given column.
	var count = 0
	for piece in table.get_pieces_of_kind(kind):
		if piece.color != color or piece.board_position.x != column:
			continue
		count += 1
	return count

func count_pieces_on_row_of_kind(table: Table, kind: String, color: String, row) -> int:
	# Count the number of pieces of the kind specified in the given row
	var count = 0
	for piece in table.get_pieces_of_kind(kind):
		if piece.color != color or piece.board_position.y != row:
			continue
		count += 1
	return count
	
	
func can_piece_move_to(table: Table, piece, target: Vector2) -> bool:
	# Returns True if the piece located at the given position can move to a target pos.
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

