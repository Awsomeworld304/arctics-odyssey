extends Node
class_name ChartMetadata

var song_name:String;
var characters:Array[String];
var charts:Dictionary[String, String];

static func find_files(directory:String, file_type:String) -> Array[String]:
	var files:Array[String] = [];
	var dir:DirAccess = DirAccess.open(directory);
	if not dir:
		push_error("Failed to open directory: %s" % directory);
		return files;

	dir.list_dir_begin();
	var file_name:String = dir.get_next();
	while file_name != "":
		if file_name.ends_with(".%s" % file_type) and file_name != "metadata.json" and !file_name.contains("event"):
			files.append(dir.get_current_dir() + "/" + file_name + ".%s" % file_type);
		file_name = dir.get_next();
	dir.list_dir_end();
	return files;

## Function to parse metadata.
## Returns a String, String dictionary with serialized metadata.
static func parse_metadata(metadata_path:String) -> Dictionary:
	var data:Dictionary = {};
	if metadata_path.is_empty() or not FileAccess.file_exists(metadata_path): push_error("ChartMetadata -> Parse (%s): Metadata path is null." % data["song"]); return data;
	
	var file:FileAccess = FileAccess.open(metadata_path, FileAccess.READ);
	data = JSON.parse_string(file.get_as_text());
	
	if data.get_or_add("song", "") == "":
		data["song"] = "NO NAME";
		push_error("ChartMetadata -> Parse (%s): Song name is null, setting to \"NO NAME\"." % data["song"]);
		pass
	
	if data.get_or_add("characters", []) == []:
		push_error("ChartMetadata -> Parse (%s): No characters, adding default player." % data["song"]);
		data["characters"] = ["player"];
		pass
	
	if data.get_or_add("charts", {}) == {}:
		push_warning("ChartMetadata -> Parse (%s): No charts! Attempting to find defaults." % data["song"]);
		var new_dat:Dictionary[String,String] = {};
		
		for chart in find_files(metadata_path.get_base_dir(), "json"):
			if chart.contains("-"): new_dat[chart.split("-")[1]] = chart;
			else: new_dat["normal"] = chart;
			pass
		
		if !new_dat.is_empty():
			if Settings.debug: print("ChartMetadata -> Parse (%s): Found new chart data: %s" % [data["song"], new_dat]);
			data["charts"] = new_dat;
			pass
		else: push_error("ChartMetadata -> Parse (%s): No charts found in song folder!" % data["song"]);
		pass
	
	if data.get_or_add("audio", []) == []:
		push_warning("ChartMetadata -> Parse (%s): No audio! Attempting to find defaults." % data["song"]);
		var new_dat:Array[String] = [];
		
		for audio in find_files(metadata_path.get_base_dir(), "ogg"):
			new_dat.append(audio);
			pass
		
		if new_dat != []:
			if Settings.debug: print("ChartMetadata -> Parse (%s): Found new audio data: %s" % [data["song"], new_dat]);
			data["audio"] = new_dat;
			pass
		else: push_error("ChartMetadata -> Parse (%s): No audio data found in song folder!" % data["song"]);
		pass
	return data;
