extends Node

onready var game = get_node("../GameRules")

func get_column_name(x):
	return ["a", "b", "c", "d", "e", "f", "g", "h"][x-1]

func get_piece_id(piece):
	return { "king": "K", "queen": "Q", "rook": "R", "bishop": "B", "knight": "N" }.get(piece)

func get_cell_name(pos):
	return get_column_name(pos.x) + String(int(pos.y))
	

func get_moves_from_algebra(algebra):
	var moves = [
		game.Move.new(Vector2(5, 2), Vector2(5,4)),
	]
	return moves


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


	# Add + or ++ if king is on check[mate]
	if game._is_check(table_after_move, game.get_opposite_color(color)):
		notation += "+"
		if game._is_check_mate(table_after_move, moves, game.get_opposite_color(color)):
			notation = "#"
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
