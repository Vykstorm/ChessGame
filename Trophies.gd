extends TileMap


func clear_trophies():
	self.clear()

func sort_trophies(a, b):
	var trophies_order = ["queen", "rook", "bishop", "knight", "pawn"]
	return trophies_order.find(b[0]) > trophies_order.find(a[0])
	
func set_trophies(trophies: Array):
	clear_trophies()
	var pictures = ["queen", "king", "rook", "knight", "bishop", "pawn"];
	
	trophies.sort_custom(self, "sort_trophies")

	var x = 0
	var y = 0
	for trophy in trophies:
		var kind = trophy[0]
		var amount = trophy[1]
		for j in range(0, amount):
			self.set_cell(x, y, pictures.find(kind))
			x += 1
			if x == 10:
				x = 0
				y += 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
