extends Node

onready var game = get_node("../GameRules")

func get_column_name(x) -> String:
	return ["a", "b", "c", "d", "e", "f", "g", "h"][x-1]
	
func get_column_from_name(x: String) -> int:
	return "abcdefgh".find(x) + 1

func get_piece_id(piece: String) -> String:
	return { "king": "K", "queen": "Q", "rook": "R", "bishop": "B", "knight": "N" }.get(piece)
	
func get_piece_name_from_id(id: String) -> String:
	return { "K": "king", "Q": "queen", "R": "rook", "B": "bishop", "N": "knight" }.get(id)

func is_piece_id(x: String) -> bool:
	return x in "KQRBN"

func get_cell_name(pos: Vector2) -> String:
	return get_column_name(pos.x) + String(int(pos.y))
	
func get_cell_from_name(name: String) -> Vector2:
	return Vector2(get_column_from_name(name[0]), int(name[1]))
	


func desambiguate_source_cell_name(table, move) -> String:
	# Parameters: The board and a move is passed. ( The moving piece cannot be a pawn )
	# Returns:
	# An empty string if only 1 piece of the same kind as the one that performs the move
	# can go to the target cell
	# Otherwise, returns the source cell coordinates in algebra notation:
	# - If the moving piece is placed in a different row than others, only the name of the row
	# is returned (A,B,C,D,...)
	# - Otherwise. If the moving is placed in a different rank than others, return its rank number
	# - Default: Returns both the row and the rank of the source cell. 
	var target_pos = move.to
	var source_pos = move.from
	var moving_piece = table.get_kind(source_pos)
	var color = table.get_color(source_pos)
	
	# Is there only 1 piece on the same row as the moving piece?
	if game.count_pieces_on_column_of_kind(table, moving_piece, color, source_pos.x) == 1:
		return get_column_name(source_pos.x)
	# Otherwise, is there only 1 piece on the same column?
	if game.count_pieces_on_row_of_kind(table, moving_piece, color, source_pos.y) == 1:
		return String(source_pos.y)
	# Otherwise returns the row and rank
	return get_cell_name(source_pos)
	
	
	

func get_algebra_for_last_move(table, table_after_move, moves) -> String:
	var move = moves[-1]
	
	var target_pos = move.to
	var source_pos = move.from
	var moving_piece = table.get_kind(source_pos)
	var color = table.get_color(source_pos)
	
	var notation
	
	if move is game.CastlingMove:
		# O-O for castling to the kingside and O-O-O for queenside
		if move.get_rook_source_pos().x == 8:
			notation = "O-O"
		else:
			notation = "O-O-O"
		
	elif move is game.PromotionMove:
		# Notation for promotion moves.
		# e.g: e8=Q
		var promotion = "queen" if move.promotion == null else move.promotion
		notation = get_cell_name(target_pos) + "=" + get_piece_id(promotion)
		
	
	else:
		if moving_piece == "pawn":
			if source_pos.x == target_pos.x:
				# Pawn move forward
				notation = get_cell_name(target_pos)
			else:
				# Pawn capture
				notation = get_column_name(source_pos.x) + "x" + get_cell_name(target_pos)
		else:
			# This variable will indicate the file/column (or both) of the source cell of the moving
			# piece to desambiguate the move notation (in case that more than one piece of the same
			# kind can move to the target cell)
			
			# Check if there is any other piece of the same kind which can move also the same
			# target.
			var desambiguate_source_pos: bool=false
			
			for piece in table.get_pieces_of_kind(moving_piece):
				if piece.color != color or piece.board_position == source_pos:
					continue
				if game.can_piece_move_to(table, piece, target_pos):
					desambiguate_source_pos = true
					break
			
			var source_cell_name
			if desambiguate_source_pos:
				source_cell_name = desambiguate_source_cell_name(table, move)
			else:
				source_cell_name = ""
		

			if table.is_empty(target_pos):
				# Piece move
				notation = get_piece_id(moving_piece) + source_cell_name + get_cell_name(target_pos)
			else:
				# Piece capture
				notation = get_piece_id(moving_piece) + source_cell_name + "x" + get_cell_name(target_pos)


	# Add + or # if king is on check[mate]
	if game._is_check(table_after_move, game.get_opposite_color(color)):	
		if game._is_check_mate(table_after_move, moves, game.get_opposite_color(color)):
			notation += "#"
		else:
			notation += "+"
	return notation



func get_algebra_from_moves(moves):
	var table = game.create_table(game.get_initial_pieces())
	var algebra = []
	var moves_done = []
	for move in moves:
		moves_done.append(move)
		var table_after_move = table.apply_move(move)
		algebra.append(get_algebra_for_last_move(table, table_after_move, moves_done))
		table = table_after_move
	return algebra


func parse_algebra_move_notation(table, color, algebra_move: String) -> Dictionary:
	# * In case of a regular move...
	# Returns a dictionary holding the next items:
	# - type: normal/castling (indicates the kind of move).
	# - info: A dictionary with the next items. If type=normal ...
	# 	- source: 		Source position of the piece which is moved
	# 	- target: 		Target position of the piece
# 	#   - piece: 		Kind of piece that moves
	# 	- capture: 		True if the movement is a capture. False otherwise
	# 	- promotion: 	null if it is not a promotion move. Otherwise, indicates the kind of piece
	# 					that replaces the pawn in the promotion move (kind=pawn)
	# 					checkmate: In case this move is a chceckmate, it's set to True
	# 	If type=castling...
	# - info:
	#		- kind: queenside/kingside
	# Returns null in case of parsing error.
	
	if algebra_move in ["O-O", "O-O-O"]:
		return {
			"type": "castling",
			"info": {
				"kind": "kingside" if algebra_move == "O-O" else "queenside"
			}
		}
	
	var source_pos
	var target_pos
	var piece
	var promotion = null

	var capture = algebra_move.find("x") != -1
	
	# Get source cell position
	if is_piece_id(algebra_move.substr(0,1)):
		# Not a pawn move
		piece = get_piece_name_from_id(algebra_move.substr(0,1))
		# 4 syntaxis for source cell position:
		# e, e4, 4 or not specified. e.g: Qd6 Qxd6
		var target_offset
		if (not capture and len(algebra_move) == 3) or (capture and len(algebra_move) == 4):
			source_pos = table.find_piece(piece, color).board_position
			target_offset = 1
			
		elif algebra_move.substr(0,1).is_valid_integer():
			# Find piece of the given kind in the specified row
			# 4
			source_pos = table.find_piece_on_row(piece, color, algebra_move.substr(0,1).to_int()).board_position
			target_offset = 2
		
		elif algebra_move.substr(1,1).is_valid_integer():
			# Both row and column was specified
			# e4
			source_pos = get_cell_from_name(algebra_move.substr(0,2))
			target_offset = 3
		else:
			# Only column was specified
			source_pos = table.find_piece_on_column(piece, color, get_column_from_name(algebra_move.substr(0,1)) ).board_position
			target_offset = 2
		
		if capture:
			target_offset += 1
		target_pos = get_cell_from_name(algebra_move.substr(target_offset, 2))

	else:
		# Pawn move
		piece = "pawn"
		if not capture:
			# Move without capture
			# Notation: e4, f3, ...
			target_pos = get_cell_from_name(algebra_move.substr(0, 2))
			source_pos = table.find_piece_on_column("pawn", color, target_pos.x).board_position
			
		else:
			# Move with capture
			# exd5, fxg4, ...
			target_pos = get_cell_from_name(algebra_move.substr(2, 2))
			source_pos = table.find_piece_on_column("pawn", color, get_column_from_name(algebra_move.substr(0, 1))).board_position
		
		
	return {
		"type": "normal",
		"info": {
			"source": source_pos,
			"target": target_pos,
			"piece": piece,
			"capture": capture,
			"promotion": promotion
		}
	}


func get_moves_from_algebra(algebra_moves: Array):
	# Returns a sequence of moves specified by the given algebra notation.
	var moves = []
	
	var table = game.create_table(game.get_initial_pieces())
	var color = "white"
	
	for algebra_move in algebra_moves:
		var parsed_algebra = parse_algebra_move_notation(table, color, algebra_move)
		var info = parsed_algebra["info"]
		var move
		
		if parsed_algebra["type"] == "castling":
			# Castling move
			var castling_type = info["kind"]
			move = game.CastlingMove.new(color, castling_type)
		else:
			# Normal move
			
			var kind = info["piece"]
			var source_pos = info["source"]
			var target_pos = info["target"]
			var is_capture = info["capture"]
			
			if kind == "pawn":
				var promotion = info["promotion"]
				if promotion != null:
					# Promotion move.
					move = game.PromotionMove.new(source_pos, target_pos, promotion)
				else:
					move = game.Move.new(source_pos, target_pos)
					if is_capture and table.is_empty(target_pos):
						# En passant capture
						if color == "white":
							move.piece_to_kill = Vector2(target_pos.x, target_pos.y-1)
						else:
							move.piece_to_kill = Vector2(target_pos.x, target_pos.y+1)
			else:
				# Not a pawn move
				move = game.Move.new(source_pos, target_pos)
				
			
		table = table.apply_move(move)
		moves.append(move)
		color = game.get_opposite_color(color)
	return moves
