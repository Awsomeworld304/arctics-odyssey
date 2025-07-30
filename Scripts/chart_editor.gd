extends Node2D

# Strumline Stuff
@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;
@onready var strum:Strumline = $"hud/player/Strumline" as Strumline;
@onready var ui_RATING:Label = $"hud/player/Strumline/Rating" as Label;

# UI Stuff
@onready var songName:Label = $main/ChartMenu/Chart/ChartName as Label;
@onready var editorGrid:GridPanel = $"hud/player/Strumline/GridPanel" as GridPanel;
@onready var timeSlider:HSlider = $"main/TimeSlider" as HSlider;
@onready var timeLabel:Label = $"main/SongTime" as Label;

## How many notes have been hit.
var hit_notes:int = 0;

## Path to current chart.
var current_chart:String = "";

## Time slider is currently dragging.
var timeSlider_is_dragging:bool = false;
## Time slider, paused before dragging.
var timeSlider_prev_paused:bool = false;

func sec_to_px(note:Note) -> float:
	return note.time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func px_to_sec(px:float) -> float:
	return px / (Conductor.bpm/60) / (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func beat_to_sec(beats: float) -> float:
	return (beats * 60.0) / Conductor.bpm;

func _enter_tree() -> void:
	pass

func on_hit_note(_note:Note) -> void:
	hit_notes += 1;
	pass

func load_song(chart_path:String) -> void:
	var chartData:Chart = Chart.new();

	chartData = Chart._parse_chart(chart_path);
	Conductor.bpm = chartData.song_bpm;
	Conductor.scroll_speed = chartData.note_speed;
	strum.strumline_id = &"edit";
	strum.ui_SLID.text = "SLID: edit";
	strum.load_chart(chartData);
	Conductor.stop();
	songName.text = chartData.song.capitalize();
	Conductor.play();
	Conductor.pause();
	Conductor.position = 0;

	editorGrid.tile_offset.y = floori(Conductor.get_beat_time() * (float(Conductor.scroll_speed) * Conductor._offset_scroll_modifier));
	editorGrid.grid_height = Conductor._num_beats_in_song;
	timeSlider.max_value = player.stream.get_length();
	pass

func spawn_stage() -> void:
	pass

func _ready() -> void:
	#strum.bot_strumline = true;
	ui_RATING.modulate = Color.TRANSPARENT;
	Conductor.player = player;

	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	_s = strum.note_hit.connect(on_hit_note);
	_s = timeSlider.drag_started.connect(drag_started);

	load_song("user://Mods/Songs/beat_test/beat_test.json");
	pass

var total_beat:int = 0;
var total_fract:int = 0;
func _song_info() -> void:
	text = "Cached Latency: " + var_to_str(Conductor._cached_latency) + "\n";
	text += "Measure: " + var_to_str(int(float(total_beat)/4)+1) + "\n";
	text += "Beat: " + var_to_str((total_beat % Conductor.curr_time_signature.numerator) +1) + " (" +var_to_str(total_beat+1) + ")\n";
	text += "Step: " + var_to_str((((total_beat % Conductor.curr_time_signature.numerator)*4)+total_fract) +1) + " (" + var_to_str((total_beat*4)+total_fract+1) + ")\n";
	text += "Total beats: " + var_to_str(Conductor._num_beats_in_song) + "\n";
	text += "Offset (ms): " + var_to_str(Conductor.audio_offset_ms) + "\n";
	text += "Prev. time (sec): \n" + var_to_str(Conductor._prev_time_seconds) + "\n";
	text += "Position (sec): \n" + var_to_str(Conductor.position) + "\n";
	text += "Hit Notes: " + var_to_str(hit_notes) + "\n";
	text += "SLID: " + strum.strumline_id + "\n";
	($"main/debuginfo" as RichTextLabel).text = text;
	pass

var text:String = "";
func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug2"): Conductor.pause();
	if Conductor._activated: _song_info();

	if !timeSlider_is_dragging: timeSlider.value = Conductor.position;
	timeLabel.text = "[%s / %s]" % [format_time(Conductor.position), format_time(int(player.stream.get_length()))];
	pass


func _beat_pass(beat: int) -> void:
	total_beat = beat;
	pass

func _step_pass(_beat:int, fract:int) -> void:
	total_fract = fract;
	pass

func drag_started() -> void:
	if Conductor.is_playing:
		timeSlider_prev_paused = false;
		Conductor.pause();
		pass
	elif Conductor.is_paused: timeSlider_prev_paused = true;
	timeSlider_is_dragging = true;
	pass

func format_time(seconds:float) -> String:
	return "%d:%02d" % [(floor(seconds) / 60), floor(int(seconds) % 60)];

func _on_time_slider_drag_ended(_value_changed: bool) -> void:
	# Set the position.
	Conductor.set_song_position(timeSlider.value);
	timeSlider_is_dragging = false;
	# Position is updated, so update UI to match.
	timeSlider.value = Conductor.position;

	if !timeSlider_prev_paused: Conductor.pause();
	pass

func _on_tree_exiting() -> void:
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	pass

func _on_stop_chart_button_up() -> void:
	timeSlider.value = Conductor.position;
	Conductor.stop(true);
	strum.reset();
	timeSlider_is_dragging = false;
	timeSlider_prev_paused = false;
	timeSlider.value = 0;
	pass

func _on_play_chart_button_up() -> void:
	pass

func _on_time_slider_value_changed(value: float) -> void:
	if Conductor.is_playing and !Conductor.is_paused: return;
	Conductor.position = value;
	pass
