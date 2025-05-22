class_name Chart
extends Node

@export var chart_path:String;
var _chart:Dictionary;
var notes:Array[Note];
var song:String = "";
var character:String = "";
var note_speed:int = 1;

func _init(chart_path:String = "") -> void:
	if chart_path != "":
		_chart = _parse_chart(chart_path);
		pass
	pass

func _ready() -> void:
	pass

func _parse_chart(path:String) -> Dictionary:
	var chart:Dictionary;
	# Null Check 1
	if not FileAccess.file_exists(path): 
		push_error("Chart -> Chart does not exist! " + path);
		return chart;
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);

	# Null Check 2
	if file == null or file.get_error() != OK or FileAccess.get_open_error() != OK:
		push_error("Chart -> FileAccess error: " + var_to_str(file.get_error()) + " " + var_to_str(FileAccess.get_open_error()));
		return chart;
	
		# Check JSON
	var json_pstring:String = file.get_as_text();
	var json:JSON = JSON.new();
	var parse_result:Error = json.parse(json_pstring);
	if not parse_result == OK:
		push_warning("Chart -> JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
		return chart;
	# We got our data.
	var parsed_data:Dictionary = json.get_data();

	song = parsed_data["song"];
	character = parsed_data["character"];
	var noteData:Array = parsed_data["notes"]["normal"] as Array;
	for dat in noteData:
		var note:Note = Note.new();
		note.data = NoteData.new();
		note.key_name = dat["key_name"];
		note.data.key_name = dat["key_name"];
		note.data.time = dat["time"];
		note.add_to_group(note.key_name);
		notes.append(note);
		pass
	file.close();
	return chart;
