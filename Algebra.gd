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
		pass
	
	else:
		if moving_piece == "pawn":
			if source_pos.x == target_pos.x:
				# Pawn move forward
				notation = get_cell_name(target_pos)
			else:
				# Pawn capture
				notation = get_column_name(source_pos.x) + "x" + get_cell_name(target_pos)
		else:
			if table.is_empty(target_pos):
				# Piece move
				notation = get_piece_id(moving_piece) + get_cell_name(target_pos)
			else:
				# Piece capture
				notation = get_piece_id(moving_piece) + "x" + get_cell_name(target_pos)


	# Add + or ++ if king is on check[mate]
	if game._is_check(table_after_move, game.get_opposite_color(color)):
		notation += "+"
		if game._is_check_mate(table_after_move, moves, game.get_opposite_color(color)):
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
