extends Node

## Script Types
enum {
	DIALOG, ## The dialog script type.
	EVENT, ## The event script type.
	GENRAL ## The general script type.[br] This is used for campaign scripting and custom single use cases.
}

signal saved_script(script_name);
signal loaded_script(script_name);

func _ready() -> void:
	# Did this to prevent the game locking during save and causing havoc to my stack.
	process_mode = Node.PROCESS_MODE_ALWAYS;
	pass

## Loads a request script at the requested path.[br]
## The file is the file name, filetypes are handled automatically.[br]
## The path is to the directory of the file, [b]not[/b] the file.[br]
## Emits a signal [loaded_script(file_name)].
func load_script(file, path := "res://Assets/") -> Dictionary:
	var load_file:Dictionary;
	var fpath = path + file + ".script";
	
	if !DirAccess.dir_exists_absolute(path):
		push_warning("StoryManager -> Can't find requested script directory!");
		return load_file;

	if not FileAccess.file_exists(fpath):
		push_warning("StoryManager -> Can't find requested script!");
		return load_file;

	# Load Data from File
	var save_read = FileAccess.open(fpath, FileAccess.READ);
	if save_read != null:
		while save_read.get_position() < save_read.get_length():
			var json_pstring = save_read.get_line();
			var json = JSON.new();
			var parse_result = json.parse(json_pstring);
			if not parse_result == OK:
				printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
				LevelManager.errCode = parse_result 
				return parse_result;
			load_file = json.get_data();
	loaded_script.emit(file as String);
	return load_file;

## Saves a script.[br]
## The path is to the directory you wish to save to.[br]
## The code handles the filetype automaticlly.[br]
## Emits a signal [saved_script(file_name)].
func save_script(script:Dictionary, path := "res://Assets/") -> Error:
	# Setup File
	var fpath = path + script.name + ".script";
	var save:Dictionary = script;
	script.get(name)
	print(script.get(name));
	# Save to File
	if !DirAccess.dir_exists_absolute(path):
		push_warning("StoryManager -> Directory does not exist, creating directory.");
		DirAccess.make_dir_recursive_absolute(path);
	var save_write := FileAccess.open(fpath, FileAccess.WRITE);
	if (save_write == null):
		var e:int = FileAccess.get_open_error();
		printerr("StoryManager -> ERROR: Can't open script for write: " + var_to_str(e));
		return e as Error;
	var json_string = JSON.stringify(save);
	save_write.store_line(json_string);
	save_write.close();
	saved_script.emit(script.name as String);
	return OK;