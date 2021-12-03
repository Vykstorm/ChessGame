extends Node

enum {A=1, B=2, C=3, D=4, E=5, F=6, G=7, H=8}

onready var Piece = preload("res://Piece.tscn")


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
	
	var instances = []
	for info in pieces:
		var instance = Piece.instance()
		instance.kind = info[0]
		instance.color = info[1]
		instance.board_position = Vector2(info[2], info[3])
		instances.append(instance)
	return instances


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

