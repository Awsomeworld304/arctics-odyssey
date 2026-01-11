extends Panel

@onready var chart_name_lbl:Label = $pick_chart/cht_name as Label;
@onready var dialog:FileDialog = $FileDialog as FileDialog;
@onready var sdialog:FileDialog = $SaveDialog as FileDialog;
@onready var exit:Button = $chart_exit as Button;
@onready var info:RichTextLabel = $info as RichTextLabel;

var loaded_chart:bool = false;
var already_ao_chart:bool = false;
var lcd:Chart;

func _ready() -> void:
	pass


func _on_pick_chart_button_up() -> void:
	dialog.visible = true;
	pass


func _on_file_dialog_file_selected(path: String) -> void:
	info.text = "";
	if loaded_chart:
		lcd = null;
		loaded_chart = false;
		already_ao_chart = false;
		pass
	
	var file:FileAccess = FileAccess.open(path, FileAccess.READ);
	if not file:
		info.text = "[color=red]Failed to read chart![/color]\n%s" % path;
		return;
	
	var json:JSON = JSON.new();
	var result:Error = json.parse(file.get_as_text());
	if result != OK:
		info.text = "[color=red]Failed to parse chart json![/color]\n%s\n%s" % [json.get_error_message(), path];
		return;
	
	if json.data is Dictionary:
		var dat:Dictionary = json.data as Dictionary;
		lcd = convert_chart(dat, path);
	else:
		info.text = "[color=red]Failed to parse chart data! (Invalid struct?)[/color]\n%s" % [path];
		return;
	
	if lcd == null: return;
	
	info.text = "%sChart: %s\nBPM: %s\nNote Speed: %s\nNote Count: %s\nTime Sig: %s" % ["[color=yellow]WARNING: Loaded an AO chart.[/color]" if already_ao_chart else "", lcd.song, lcd.song_bpm, lcd.note_speed, lcd.notes.size(), lcd.time_signature._to_string()];
	loaded_chart = true;
	pass

func convert_chart(chart_data:Dictionary, path:String) -> Chart:
	var chart:Chart = Chart.new();
	
	if Chart.validate_chart(Chart._parse_json_data(chart_data, path)) == OK:
		already_ao_chart = true;
		chart = Chart._parse_json_data(chart_data, path);
		return chart;
	
	var notes:Array[Note] = [];
	var song_data:Dictionary = chart_data.get("song", {});
	var sections:Array = song_data.get("notes", []);
	
	chart.song_bpm = song_data.get("bpm", 100);
	chart.song = song_data.get("song", "Untitled");
	if song_data.get("song") == null: print("Chart Converter -> Convert: Error trying to get song name. It's null.")
	chart.note_speed = song_data.get("speed", 1);
	
	var player_one:Character = Character.new();
	var player_two:Character = Character.new();
	player_one.character_name = str(song_data.get("player1", "none"));
	chart.characters.append(player_one);
	player_two.character_name = str(song_data.get("player2", "none"));
	chart.characters.append(player_two);
	
	for section:Dictionary in sections:
		var must_hit:bool = section.get("mustHitSection", true);
		#if !must_hit: continue;
		
		var section_notes:Array = section.get("sectionNotes", []);
		#var section_bpm:float = section.get("bpm", bpm) if section.get("changeBPM", false) else bpm;
		var section_beats:int = section.get("sectionBeats", 4);
		chart.time_signature = Conductor.TimeSignature.new(section_beats, 4);
		if section_notes.is_empty(): continue;
		for note_data:Array in section_notes:
			if note_data.size() >= 3:
				var time_ms:float = note_data[0];
				var lane:int = note_data[1];
				var sustain_ms:float = note_data[2];
				var note:Note = Note.new();
				note.time = time_ms / 1000.0;
				note.hold_time = sustain_ms / 1000.0;
				
				match lane:
					0: note.key_name = "left";
					1: note.key_name = "down";
					2: note.key_name = "up";
					3: note.key_name = "right";
					_: continue;
				
				#FIXME: Figure out how to handle sustain later.
				
				notes.append(note)
				pass
			pass
		pass
	
	chart.notes = notes;
	
	if Chart.validate_chart(chart) != OK:
		info.text = "[color=red]Failed to parse chart data! (Failed final validation check.)[/color]";
		return null;
	return chart;


func _on_chart_exit_button_up() -> void:
	self.visible = false;
	pass


func _on_clear_chart_button_up() -> void:
	lcd = null;
	loaded_chart = false;
	info.text = "";
	already_ao_chart = false;
	pass


func _on_save_chart_button_up() -> void:
	sdialog.visible = true;
	pass


func _on_save_dialog_file_selected(path: String) -> void:
	print("ready to save chart %s" % path)
	lcd._save_chart(path);
	pass
