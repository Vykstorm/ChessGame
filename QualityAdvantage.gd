extends Control

onready var white = $White
onready var black = $Black

func number_to_string(x: int):
	return "+" + str(x)

func set_value(advantage: int):
	# Set the quality advantage. A value > 0 indicates a positive advantage for the white player.
	if advantage == 0:
		white.text = ""
		black.text = ""
	elif advantage > 0:
		white.text = number_to_string(advantage)
		black.text = ""
	else:
		white.text = ""
		black.text = number_to_string(-advantage)

