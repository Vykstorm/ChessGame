extends Node

export var game_files_path = "user://"


func get_files_in_dir(path: String) -> Array:
	# Returns all the files in the given directory
	var directory: Directory = Directory.new()
	var err = directory.open(path)
	assert(err == OK)
	
	var files = []
	directory.list_dir_begin(true, true)
	var file = directory.get_next()
	while file != "":
		files.append(file)
		file = directory.get_next()
	return files
	
func remove_file(file_path: String):
	var dir = Directory.new()
	var err = dir.remove(file_path)
	assert(err == OK)
	
func is_game_file(file_path: String) -> bool:
	# Returns false if the given file path doesn't correspond to a game file.
	var gameFilePathRegex = RegEx.new()
	gameFilePathRegex.compile("(\\d+)\\.pgn$")
	var result = gameFilePathRegex.search(file_path)
	return result != null
	
	
func get_file_path_for_game_id(id: String) -> String:
	# Returns the path of the game file with the given id.
	return game_files_path + "match-" + id  + ".pgn"
	
	
	
	
func get_game_files() -> Array:
	# Return all the stored game file paths.
	var game_files = []
	for file_path in get_files_in_dir(game_files_path):
		if not is_game_file(file_path):
			continue
		game_files.append( file_path )
	return game_files
	

func get_game_id_from_file_path(file_path: String) -> String:
	# Returns the id for the game file with the specified game path.
	var gameFilePathRegex = RegEx.new()
	gameFilePathRegex.compile("(\\d+)\\.pgn$")
	var result = gameFilePathRegex.search(file_path)
	assert(result != null)
	return result.get_string(1)


func new_game() -> String:
	# Creates a new empty game and saves it in a database.
	# Returns its ID
	var id: String = String(OS.get_unix_time())
	Pgn.export_algebra_to_pgn_file([], get_game_pgn_file(id), {})
	return id
	
func delete_game(id: String):
	# Delete the game with the given ID.
	var file_path = get_file_path_for_game_id(id)
	remove_file(file_path)
	
	
func _sort_ids(a: String, b: String) -> bool:
	return int(b) < int(a)
	
func get_games() -> Array:
	# Returns the IDs of all the games stored sorted from the most to least recent one created.
	var ids = []
	for file_path in get_game_files():
		ids.append(get_game_id_from_file_path(file_path))
	# Sort IDs
	ids.sort_custom(self, "_sort_ids")
	return ids
	
func get_game_pgn_file(id: String) -> String:
	# Returns the path of the pgn file associated
	# to the game with the specified ID
	return get_file_path_for_game_id(id)
