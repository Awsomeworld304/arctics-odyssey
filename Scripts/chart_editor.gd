extends Node2D

# Strumline Stuff
@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;
@onready var strum:Strumline = $"hud/player/Strumline" as Strumline;
@onready var ui_RATING:Label = $"hud/player/Strumline/Rating" as Label;

# UI Stuff
@onready var songName:Label = $main/ChartMenu/Chart/ChartName as Label;

## How many notes have been hit.
var hit_notes:int = 0;

## Path to current chart.
var current_chart:String = "";

func sec_to_px(note:Note) -> float:
	return note.time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func px_to_sec(px:float) -> float:
	return px / (Conductor.bpm/60) / (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func beat_to_sec(beats: float) -> float:
	return (beats * 60.0) / Conductor.bpm;


func _enter_tree() -> void:
	pass

func on_hit_note(note:Note) -> void:
	hit_notes += 1;
	pass

func load_song(chart_path:String) -> void:
	var chartData:Chart = Chart.new();
	
	chartData = Chart._parse_chart(chart_path);
	Conductor.bpm = chartData.song_bpm;
	Conductor.scroll_speed = chartData.note_speed;
	strum.load_chart(chartData);
	Conductor.stop();
	songName.text = chartData.song.capitalize();
	Conductor.play();
	Conductor.pause();
	Conductor.position = 0;
	pass

func spawn_stage() -> void:
	pass

func _ready() -> void:
	#strum.bot_strumline = true;
	ui_RATING.modulate = Color.TRANSPARENT;
	Conductor.player = player;
	
	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	strum.note_hit.connect(on_hit_note);
	
	load_song("user://Mods/Songs/beat_test/beat_test.json");
	pass

var total_beat:int = 0;
var total_fract:int = 0;
func _song_info() -> void:
	text = "Cached Latency: " + var_to_str(Conductor._cached_latency) + "\n";
	text += "Measure: " + var_to_str((total_beat/4)+1) + "\n";
	text += "Beat: " + var_to_str((total_beat % 4) +1) + " (" +var_to_str(total_beat+1) + ")\n";
	text += "Step: " + var_to_str((((total_beat%4)*4)+total_fract) +1) + " (" + var_to_str((total_beat*4)+total_fract+1) + ")\n";
	text += "Total beats: " + var_to_str(Conductor._num_beats_in_song) + "\n";
	text += "Offset (ms): " + var_to_str(Conductor.audio_offset_ms) + "\n";
	text += "Prev. time (sec): \n" + var_to_str(Conductor._prev_time_seconds) + "\n";
	text += "Position (sec): \n" + var_to_str(Conductor.position) + "\n";
	text += "Hit Notes: " + var_to_str(hit_notes) + "\n";
	($"main/debuginfo" as RichTextLabel).text = text;
	pass

var text:String = "";
func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug2"): Conductor.pause();
	if Conductor._activated: _song_info();
	pass


func _beat_pass(beat: int) -> void:
	total_beat = beat;
	pass

func _step_pass(beat:int, fract:int) -> void:
	total_fract = fract;
	pass

func _on_tree_exiting() -> void:
	Conductor.player = null;
	Conductor.is_paused = false;
	Conductor.is_playing = false;
	pass
