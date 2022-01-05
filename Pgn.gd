extends Node
#
#func get_current_date():
#	var info = OS.get_datetime(true)
#	String(info["day"]) + "/" + String(info["month"]) + "/" + String(info["year"]) + " " + String(info["hour"]) + ":" + String(info["minute"])
#	return "26/12/2021 13:27"


func set_bbcode_color(text: String, color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]" + text + "[/color]"


func format_algebra(algebra: Array, first_round=null, last_round=null, add_bbcode=false, colors=null) -> String:
	# [ "e4", "e5", "Nf3", "Nc6" ] -> "1.e4 e5 2.Nf3 Nc6"
	# first_round=1, [ "e4", "e5", "Nf3", "Nc6"  ] -> "... 2.Nf3 Nc6"
	# last_round=1, [ "e4", "e5", "Nf3", "Nc6"  ] -> "1.e4 e5 ..."
	
	if len(algebra) == 0:
		return ""
	
	assert((last_round == null or first_round == null) or first_round <= last_round)
	var num_rounds = int(ceil(float(len(algebra))/2))
	assert(last_round ==null or (last_round < num_rounds and last_round >= 0))
	assert(first_round == null or (first_round < num_rounds and first_round >= 0))
	
	if colors == null:
		colors = {}
	if colors.get("last_move") == null:
		colors["last_move"] = Color.aqua
	if colors.get("check") == null:
		colors["check"] = Color.yellow
	if colors.get("checkmate" ) == null:
		colors["checkmate"] = Color.red
	

	if first_round == null:
		first_round = 0
	if last_round == null:
		last_round = num_rounds-1
	
	var moves = ""

	if first_round > 0:
		moves += "... "
	
	var k = first_round
	while k <= last_round:
		var white_move_index = k*2
		var black_move_index = white_move_index+1
		if k > first_round:
			moves += " "
			
		moves += String(k+1)+ "."
		
		# Add white move
		var move = algebra[white_move_index]
		if add_bbcode:
			# Add color to the notation if it's the last move.
			var color
			if white_move_index == len(algebra)-1:
				if "+" in move:
					color = colors["check"]
				elif "#" in move:
					color = colors["checkmate"]
				else:
					color = colors["last_move"]
			else:
				color = Color.white
			move = set_bbcode_color(move, color)
		moves += move
		
		# Add black move
		if black_move_index < len(algebra):
			moves += " "
			# Add color to the notation if it's the last move.
			move = algebra[black_move_index]
			if add_bbcode:
				var color
				if black_move_index == len(algebra)-1:
					if "+" in move:
						color = colors["check"]
					elif "#" in move:
						color = colors["checkmate"]
					else:
						color = colors["last_move"]
				else:
					color = Color.white
				move = set_bbcode_color(move, color)
			moves += move
		k += 1
	
	if last_round < num_rounds-1:
		moves += " ..."
	
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
	moves_regex.compile("\\d+\\.([KQRNBa-h1-8xO\\-=]+[+#]?)( ([KQRNBa-h1-8xO\\-=]+[+#]?))?")
	var moves = []
	for entry in moves_regex.search_all(text):
		var white_move = entry.get_string(1)
		var black_move = entry.get_string(3)
		moves.append(white_move)
		if black_move != "":
			moves.append(black_move)
	
#	var last_move_regex = RegEx.new()
#	last_move_regex.compile("\\d+\\.([KQRNBa-h1-8xO\\-=]+[+#]?)( [^Oa-hKQRNB]|$)")
#	var entry = last_move_regex.search(text)
#	if entry:
#		var white_move = entry.get_string(1)
#		moves.append(white_move)
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
