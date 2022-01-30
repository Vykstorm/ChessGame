extends Node


func get_next_move(prev_moves, pieces, color):
	var table = GameRules.create_table(pieces)
	var ia_pieces = table.get_pieces_of_color(color)
	ia_pieces.shuffle()
	for piece in ia_pieces:
		var moves = GameRules.get_valid_moves(pieces, prev_moves, piece)
		moves.shuffle()
		if len(moves) == 0:
			continue
		
		var move = moves[0]
		return move
	# No moves can't be done!
	assert(false)
