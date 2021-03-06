extends WindowDialog

signal piece_selected


onready var queen = $QueenPromotion
onready var rook = $HBoxContainer/RookPromotion
onready var knight = $HBoxContainer/KnightPromotion
onready var bishop = $HBoxContainer/BishopPromotion


func show_popup(color):
	for piece in [queen, rook, bishop, knight]:
		if color == "white":
			piece.texture_normal.region.position.y = 60
		else:
			piece.texture_normal.region.position.y = 0
	self.popup()

func _on_QueenPromotion_pressed():
	emit_signal("piece_selected", "queen")
	
func _on_RookPromotion_pressed():
	emit_signal("piece_selected", "rook")

func _on_KnightPromotion_pressed():
	emit_signal("piece_selected", "knight")

func _on_BishopPromotion_pressed():
	emit_signal("piece_selected", "bishop")



func _on_PromotionDialog_piece_selected(_kind):
	self.hide()
