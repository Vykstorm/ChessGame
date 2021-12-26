extends Node
#
#func get_current_date():
#	var info = OS.get_datetime(true)
#	String(info["day"]) + "/" + String(info["month"]) + "/" + String(info["year"]) + " " + String(info["hour"]) + ":" + String(info["minute"])
#	return "26/12/2021 13:27"

func export_algebra_to_pgn_file(algebra: Array, file_path: String, headers: Dictionary):
	var content = ""
	# Headers to be printed in the pgn file
	for key in headers:
		content += '['+key + ' "' + headers.get(key) + '"]\n'
	
	# Chess moves
	var moves = ""
	var k = 1
	for move in algebra:
		var entry = String(k) + ". " + move
		moves += entry + " "
		k += 1

	content += "\n" + moves
	
	# Open file and save content
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(content)
	file.close()


func load_algebra_from_pgn_file() -> Array:
	return []
