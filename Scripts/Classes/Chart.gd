class_name Chart
extends Node

## The notes in the chart.
@export var notes:Array[Note] = [];
## The path to the chart.
@export var chart_path:String = "";
## The song name.
@export var song:String = "";
## Chart Characters
@export var characters:Array[Character] = [];
## The scroll speed per chart.
@export var note_speed:float = 1;
## The song bpm.
@export var song_bpm:int = 100;
## The song time signature.
var time_signature:Conductor.TimeSignature = Conductor.TimeSignature.new(4,4);
## Chart events.
@export var events:Array[Event] = [];
## Chart Format Version to prevent engine issues.
@export var chart_format_version:int = Settings.chart_version:
	set(value): push_warning("Chart -> Set: Cannot change the chart format version!");
	get: return chart_format_version;
## The user-set chart version.[br]
## This is not the same as ```chart_format_version```.
@export var chart_version:int = 0;

func _init(new_chart_path:String = "") -> void:
	if FileAccess.file_exists(new_chart_path):
		var _chart:Chart = Chart._parse_chart(new_chart_path);
		song = _chart.song;
		song_bpm = _chart.song_bpm;
		events = _chart.events;
		chart_format_version = _chart.chart_format_version;
		chart_version = _chart.chart_version;
		note_speed = _chart.note_speed;
		notes = _chart.notes;
		chart_path = new_chart_path;
		pass
	# Init chart
	else:
		song = "Untitled";
		if new_chart_path != "":
			chart_path = new_chart_path;
			pass
		else:
			chart_path = "user://Mods/Songs/%s/%s.%s" % [song, song, "tac" if !Settings.prefer_bin_charts else "pac"];
			pass
		pass
		
	pass

func _ready() -> void:
	pass

func add_note(note:Note) -> void:
	notes.append(note);
	pass

static func validate_chart(chart:Chart) -> Error:
	var _err:Error = OK;
	var valid_keys:Array = ["left","down","up","right","center"];

	if chart == null:
		push_error("Chart -> Validation: Chart is null!");
		_err = ERR_DOES_NOT_EXIST;	
		chart = Chart.new();
		chart.notes = [];
		pass

	if typeof(chart.song) != TYPE_STRING or chart.song=="" or chart.song.length() >= 256:
		push_error("Chart -> Validation: 'song' must be a non-empty string.");
		_err = ERR_INVALID_DATA;
		pass
	if typeof(chart.characters) != TYPE_ARRAY or chart.characters.size() == 0 or chart.characters.size() > 63:
		push_error("Chart -> Validation: 'characters' must contain 1 - 64 characters.");
		_err = ERR_INVALID_DATA;
		pass
	if typeof(chart.note_speed) != TYPE_FLOAT or chart.note_speed <= 0.0:
		push_error("Chart -> Validation: 'note_speed' is not valid.");
		_err = ERR_INVALID_DATA;
		pass
	if typeof(chart.notes) != TYPE_ARRAY or chart.notes.size() == 0:
		push_error("Chart -> Validation: 'notes' is missing or empty.");
		_err = ERR_INVALID_DATA;
		pass

	for i:int in chart.notes.size():
		var note:Note = chart.notes[i];
		if not note.key_name != null or typeof(note.key_name) != TYPE_STRING_NAME or not valid_keys.has(note.key_name):
			push_error("Chart -> Validation: Note %d has invalid or missing key name." % i);
			_err = ERR_INVALID_DATA;
			pass
		if not note.time != null or typeof(note.time) != TYPE_FLOAT or note.time < 0.0 or ((note.time > Conductor.player.stream.get_length()) if Conductor.player != null else false):
			push_error("Chart -> Validation: Note %d has invalid or missing time position." % i);
			_err = ERR_INVALID_DATA;
			pass
		pass

	if chart.events != null and typeof(chart.events) == TYPE_ARRAY:
		for j:int in chart.events.size():
			var event:Event = chart.events[j];
			if event.eventscript == null or event.eventscript.to_string() == "":
				push_error("Chart -> Validation: Event %d is missing a valid 'script' in Event.script." % j);
				_err = ERR_INVALID_DATA if event.eventscript.to_string() == "" else ERR_DOES_NOT_EXIST;
				pass
			pass
		pass

	# Return check.
	return _err;

static func _parse_json_data(parsed_data:Dictionary, path:String) -> Chart:
	var chart:Chart = Chart.new();
	
	if parsed_data["song"] != null:
		chart.song = str(parsed_data["song"]);
		pass
	else: chart.song = "NULL";

	if chart.chart_format_version != parsed_data["chart_format_version"]:
		push_error("Chart -> Parse: CHART FORMAT IS NOT LATEST!");
		pass

	if parsed_data["chart_version"] != null: chart.chart_version = parsed_data["chart_version"];
	else: push_error("Chart -> Parse: Chart version is null!"); chart.chart_version = 0;
	chart.chart_path = path;

	if parsed_data["song_bpm"] != null: chart.song_bpm = parsed_data["song_bpm"];
	else: push_error("Chart -> Parse: Chart bpm is null!"); chart.song_bpm = 100;

	if parsed_data["note_speed"] != null: chart.note_speed = parsed_data["note_speed"];
	else: push_error("Chart -> Parse: Chart note speed is null!"); chart.note_speed = 1;

	if chart.notes == null: chart.notes = [];
	if parsed_data["notes"] != null:
		for note_data:Dictionary in parsed_data["notes"]:
			var note:Note = Note.new();
			note.time = note_data["time"];
			note.key_name = note_data["key_name"];
			note.type = note_data["type"];
			if note_data.get("hold_time", 0.0) != 0.0: note.hold_time = note_data["hold_time"];
			chart.notes.append(note);
			pass
		pass
	else: push_error("Chart -> Parse: Notes are null!");

	"""
	if parsed_data["events"] != null:
		for event_data:Dictionary in parsed_data["events"]:
			print("Chart -> Parse: Found event %s in chart %s" % [event_data["event"], chart.song]);
			pass
		pass
	"""

	if parsed_data["characters"] != null:
		for cchar:String in parsed_data["characters"] as Array[String]:
			var nchar	:Character = Character.new();
			nchar.character_name = str(cchar);
			chart.characters.append(nchar);
			pass
		pass
	return chart;

static func _load_from_json(path:String) -> Chart:
	var chart:Chart = Chart.new();

	if not FileAccess.file_exists(path):
		push_error("Chart -> Chart does not exist! " + path);
		return null;
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);

	if file == null or file.get_error() != OK or FileAccess.get_open_error() != OK:
		push_error("Chart -> FileAccess error: " + var_to_str(file.get_error()) + " " + var_to_str(FileAccess.get_open_error()));
		return chart;

	var json_pstring:String = file.get_as_text();
	var json:JSON = JSON.new();
	var parse_result:Error = json.parse(json_pstring);
	if not parse_result == OK:
		push_warning("Chart -> JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
		return chart;

	var parsed_data:Dictionary = json.get_data();

	chart = _parse_json_data(parsed_data, path);
	return chart;

# Load Chart
static func _parse_chart(path:String) -> Chart:
	var chart:Chart;
	if ModLoader.is_json_chart(path): chart = _load_from_json(path);
	elif ModLoader.is_bin_chart(path): chart = _load_from_bin(path);
	else: chart = load_default_chart();
	return chart;

## Compile and save chart to JSON. Slower option.
func _save_chart(path:String = "") -> void:
	var save_path:String = path if (!path.is_empty()) else chart_path;
	if save_path == "":
		push_error("Chart -> No path specified for saving chart.");
		return;

	var notes_dict:Array = [];

	var saved_chars:Array[String] = [];

	for cchar:Character in characters:
		saved_chars.append(cchar.character_name);
		pass

	var data:Dictionary = {
		"song": song,
		"song_bpm": song_bpm,
		"note_speed": note_speed,
		"chart_version": chart_version,
		"chart_format_version": chart_format_version,
		"characters": saved_chars,
		"notes": notes_dict
	};

	for note:Note in notes:
		var note_dict:Dictionary = {};

		# Ensure key_name exists, or use a default value
		if note.key_name != null: note_dict.get_or_add("key_name", note.key_name);
		else:
			push_warning("Chart -> Note missing key_name, setting to 'unknown'.");
			note_dict.get_or_add("key_name", "unknown");
			pass

		# The note type
		if note.type != null: note_dict.get_or_add("type", note.type);
		else:
			push_warning("Chart -> Note missing type, setting to 'normal'.");
			note_dict.get_or_add("type", "normal");
			pass

		# Ensure note data exists
		var time_val:float = 0.0;
		if note.time != null: time_val = note.time;
		else: push_warning("Chart -> Note data missing 'time', setting to 0.0.");
		note_dict["time"] = time_val;

		notes_dict.append(note_dict);
		pass

	var json_string:String = JSON.stringify(data, "\t"); # Pretty print with tabs
	var file:FileAccess = FileAccess.open(save_path, FileAccess.WRITE);

	if file == null: push_error("Chart -> Could not open file for writing: " + save_path); return;

	if file.get_error() != OK or FileAccess.get_open_error() != OK:
		push_error("Chart -> FileAccess error while writing: " + var_to_str(file.get_error()) + " " + var_to_str(FileAccess.get_open_error()));
		return;

	var store_result:bool = file.store_string(json_string);

	if !store_result:
		push_error("Chart -> Failed to write JSON string to file: " + save_path);
		file.close();
		return;

	file.close();
	pass

static func _load_from_bin(path:String = "") -> Chart:
	var cht:Chart;
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);
	if not FileAccess.file_exists(path):
		push_error("Chart -> Chart does not exist! " + path);
		return null;
	cht = file.get_var(true);
	return cht;

func _save_chart_bin(path:String = "") -> void:
	var save_path:String = path if (!path.is_empty()) else chart_path;
	if save_path == "":
		push_error("Chart -> No path specified for saving chart.");
		return;
	var file:FileAccess = FileAccess.open(save_path, FileAccess.WRITE);
	var err:bool = file.store_var(self, true);
	if !err: push_error("Chart -> BIN Save: Error while storing chart!");
	file.close();
	pass

static func load_default_chart() -> Chart:
	var chart:Chart;
	chart = Chart._load_from_json("res://Assets/Songs/beat_test/beat_test.json");
	return chart;
