extends Node
#
#func get_current_date():
#	var info = OS.get_datetime(true)
#	String(info["day"]) + "/" + String(info["month"]) + "/" + String(info["year"]) + " " + String(info["hour"]) + ":" + String(info["minute"])
#	return "26/12/2021 13:27"


func format_algebra(algebra: Array) -> String:
	var moves = ""
	var k = 0
	while k < len(algebra)-1:
		var move_index = int(k / 2) + 1
		if move_index != 1:
			moves += " "
		moves += String(move_index)+ "." + algebra[k] + " " + algebra[k+1]
		k += 2
		
	if k < len(algebra):
		var move_index = int(k / 2) + 1
		if move_index != 1:
			moves += " "
		moves += String(move_index) + "." + algebra[k]
	return moves

func export_algebra_to_pgn_file(algebra: Array, file_path: String, headers: Dictionary):
	var content = ""
	# Headers to be printed in the pgn file
	for key in headers:
		content += '['+key + ' "' + headers.get(key) + '"]\n'
	
	# Chess moves
	content += "\n" + format_algebra(algebra)
	
	# Open file and save content
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(content)
	file.close()

func load_text_from_file(file_path: String) -> String:
	var file = File.new()
	var err = file.open(file_path, File.READ)
	assert(err == OK)
	var text = file.get_as_text()
	file.close()
	return text
	
	
func get_lines_from_file(file_path: String) -> Array:
	var content = load_text_from_file(file_path)
	var lines = []
	for line in content.split("\n"):
		line = line.strip_edges()
		if line.empty():
			continue
		lines.append(line)
	return lines


func get_moves_from_text(text: String) -> Array:
	var moves_regex = RegEx.new()
	moves_regex.compile("\\d+\\.([KQRNBa-h1-8xO\\-=]+[+#]?) ([KQRNBa-h1-8xO\\-=]+[+#]?)?")
	var moves = []
	for entry in moves_regex.search_all(text):
		moves.append(entry.get_string(1))
		moves.append(entry.get_string(2))
	
	var last_move_regex = RegEx.new()
	last_move_regex.compile("\\d+\\.([KQRNBa-h1-8xO\\-=]+[+#]?)( [^Oa-hKQRNB]|$)")
	var entry = last_move_regex.search(text)
	if entry:
		moves.append(entry.get_string(1))
	return moves


func load_algebra_from_pgn_file(file_path: String) -> Dictionary:
	var content = load_text_from_file(file_path)
	# Split file content in lines
	var lines = get_lines_from_file(file_path)
	
	
	# Get headers
	var header_regex = RegEx.new()
	header_regex.compile('\\[(\\S+) "(\\S+)"\\]')
	var headers = {}
	while not lines.empty():
		var line = lines[0]
		var result = header_regex.search(line)
		if not result:
			break
		var key = result.get_string(1)
		var value = result.get_string(2)
		headers[key] = value
		lines.pop_front()
	assert(not lines.empty())
	
	# Get moves
	var body = PoolStringArray(lines).join(" ")
	
	var moves = get_moves_from_text(body)
	return { "moves": moves, "headers": headers }
