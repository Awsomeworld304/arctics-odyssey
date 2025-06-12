extends Node2D
## The game stage. This is where the gameplay happens.
class_name Stage

# ---- AUDIO ----
@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;

# ---- STAGE ----
@onready var player_pos:Vector2 = ($"PlayerPosition" as Marker2D).position;
@onready var opponent_pos:Vector2 = ($"OpponentPosition" as Marker2D).position;

# ---- RHYTHM ----
@onready var player_strum:Strumline = $"PlayerController/Strumline" as Strumline;

# ---- DEVELOPER MENU ----
@onready var dev_songName:Label = $"DevMenu/songname" as Label;
@onready var dev_timeLabel:Label = $"DevMenu/time" as Label;
@onready var dev_timeSlider:HSlider = $"DevMenu/time_slider" as HSlider;
@onready var dev_state:Label = $"DevMenu/playing_state" as Label;
var dev_song_length:int = 0;

func on_hit_note(note:Note) -> void:
	pass

func load_song(chart_path:String) -> void:
	var chartData:Chart = Chart.new();
	
	chartData = Chart._parse_chart(chart_path);
	Conductor.bpm = chartData.song_bpm;
	Conductor.scroll_speed = chartData.note_speed;
	player_strum.load_chart(chartData);
	Conductor.stop();
	dev_songName.text = chartData.song.capitalize();
	Conductor.play();
	Conductor.pause();
	Conductor.position = 0;
	
	# ---- DEV ----
	dev_timeSlider.max_value = player.stream.get_length();
	dev_song_length = player.stream.get_length();
	pass

func _ready() -> void:
	Conductor.player = player;
	
	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	player_strum.note_hit.connect(on_hit_note);
	
	# ---- DEV
	dev_timeSlider.drag_started.connect(drag_started);
	# ----
	
	load_song("user://Mods/Songs/beat_test/beat_test.json");
	pass

func _process(delta: float) -> void:
	# ---- DEV ----
	update_dev_menu();
	pass

func _beat_pass(beat: int) -> void:
	pass

func _step_pass(beat:int, fract:int) -> void:
	pass

func _on_tree_exiting() -> void:
	Conductor.player = null;
	Conductor.is_paused = false;
	Conductor.is_playing = false;
	pass

# -------- TESTING! REMOVE AFTER DEV! --------
var is_dragging:bool = false;
func drag_started() -> void: is_dragging = true;

func format_time(seconds:float) -> String:
	return "%d:%02d" % [(int(seconds) / 60), (int(seconds) % 60)];

func update_dev_menu() -> void:
	if !is_dragging: dev_timeSlider.value = Conductor.position;
	dev_timeLabel.text = "[%s / %s]" % [format_time(Conductor.position), format_time(dev_song_length)];
	pass

func _on_time_slider_drag_ended(value_changed: bool) -> void:
	is_dragging = false;
	Conductor.set_song_position(dev_timeSlider.value);
	pass

func _on_play_button_up() -> void:
	#if !Conductor.is_playing && !Conductor._activated: Conductor.play();
	Conductor.pause();
	if Conductor.is_playing: dev_state.text = "Playing";
	elif Conductor.is_paused: dev_state.text = "Paused";
	else: dev_state.text = "Stopped";
	pass

func _on_pause_button_up() -> void:
	Conductor.pause();
	if Conductor.is_playing: dev_state.text = "Playing";
	elif Conductor.is_paused: dev_state.text = "Paused";
	else: dev_state.text = "Stopped";
	pass

func _on_stop_button_up() -> void:
	Conductor.stop();
	player_strum.reset();
	load_song("");
	if Conductor.is_playing: dev_state.text = "Playing";
	elif Conductor.is_paused: dev_state.text = "Paused";
	else: dev_state.text = "Stopped";
	pass
