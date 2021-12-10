extends TileMap


func clear_trophies():
	self.clear()

func set_trophies(trophies_count: Dictionary):
	clear_trophies()
	
	var trophies_order = ["queen", "rook", "bishop", "knight", "pawn"]
	var pictures = ["queen", "king", "rook", "knight", "bishop", "pawn"];
	
	var x = 0
	var y = 0
	for trophy in trophies_order:
		var amount = trophies_count[trophy]
		for j in range(0, amount):
			self.set_cell(x, y, pictures.find(trophy))
			x += 1
			if x == 10:
				x = 0
				y += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
