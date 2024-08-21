extends Node

var static_path = "res://Assets/Dialog/";
var curText = "";
var chapter = "test";
var dialog_file = "test";
var save_dir = static_path + chapter;
var save_path = save_dir + "/" + dialog_file + ".json";

var text = {
	0: "Yeah I'm [rainbow freq=0.1][wave]gay.[/wave][/rainbow]",
	1: "So, you got a problem with that pal?",
	2: "[color=red][wave]Fight me about it then!"
}

# Starts the cutscene that opens into the game(?)
func start():
	pass

func _process(delta: float) -> void:
	pass

var fullPath = "res://Assets/Dialog/" + dialog_file + ".script";
func load_dialog(chapter = "test", file = "test"):
	self.chapter = chapter;
	dialog_file = file;
	# Load Data from File
	if not FileAccess.file_exists(fullPath):
		push_warning("StoryManager -> Can't find requested dialog file!");
		return;
	
	var save_read = FileAccess.open(fullPath, FileAccess.READ);
	if save_read != null:
		while save_read.get_position() < save_read.get_length():
			var json_pstring = save_read.get_line();

			# Creates the helper class to interact with JSON
			var json = JSON.new();

			# Check if there is any error while parsing the JSON string, skip in case of failure
			var parse_result = json.parse(json_pstring);
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
				LevelManager.errCode = parse_result 
				
				return parse_result;
				continue;
			var parsed_data = json.get_data();
	pass

func save_dialog():
	# Setup File
	#var save = text;
	var save = {
		0: "Yeah I'm [rainbow freq=0.1][wave]gay.[/wave][/rainbow]",
		1: "So what? You got a problem with that pal?",
		2: "[color=red][wave]Fight me about it then!"
	}
	# Save to File
	if !DirAccess.dir_exists_absolute(static_path):
		DirAccess.make_dir_absolute(static_path);
	var save_write = FileAccess.open(save_path, FileAccess.WRITE);
	var json_string = JSON.stringify(save);
	save_write.store_line(json_string);
	save_write.close();
	pass
