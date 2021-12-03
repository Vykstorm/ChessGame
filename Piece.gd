extends Sprite

export var kind = "king" setget set_kind
export var color = "black" setget set_color
export (Vector2) var board_position setget set_board_position, get_board_position

# A reference to the board
var board = null

func set_board_position(pos):
	var y = 8-pos.y
	var x = pos.x-1
	position = board.position + board.map_to_world(Vector2(x,y))
	board_position = pos

func get_board_position():
	return board_position


func update_picture():
	var piece_kinds = [ "queen", "king", "rook", "knight", "bishop", "pawn" ]
	var i = piece_kinds.find(kind)
	var j = 0 if color == "black" else 1
	texture.region.position.x = i * 60
	texture.region.position.y = j * 60

func set_kind(x):
	kind = x
	update_picture()

func set_color(x):
	color = x
	update_picture()
	


# Called when the node enters the scene tree for the first time.
func _ready():
	# Assign the texture properly depending on the
	# piece color and kind
	texture = texture.duplicate()
