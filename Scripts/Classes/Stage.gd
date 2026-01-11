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
@onready var opp_strum:Strumline = $"OpponentStrumline" as Strumline;

# ---- PLAYER ----
@onready var player_health:TextureProgressBar = $PlayerController/HPBar as TextureProgressBar;

# ---- DEVELOPER MENU ----
@onready var dev_songName:Label = $"DevMenu/songname" as Label;
@onready var dev_timeLabel:Label = $"DevMenu/time" as Label;
@onready var dev_timeSlider:HSlider = $"DevMenu/time_slider" as HSlider;
@onready var dev_state:Label = $"DevMenu/playing_state" as Label;
var dev_song_length:int = 0;

func on_hit_note(_note:Note) -> void:
	print("Stage -> Hit Note");
	phealth += 5;
	pass

var phealth:int = 100;
func on_miss_note(_note:Note) -> void:
	print("Stage -> Miss Note");
	phealth -= 5;
	get_tree().create_tween().tween_property(player_health, "value", phealth, 0.2).from_current();
	pass

func load_song(chart_path:String) -> void:
	var chartData:Chart = Chart.new();
	
	chartData = Chart._parse_chart(chart_path);
	Conductor.bpm = chartData.song_bpm if (chartData != null) else 100;
	Conductor.scroll_speed = chartData.note_speed if (chartData != null) else 1;
	
	player_strum.load_chart(chartData);
	opp_strum.load_chart(Chart._parse_chart(chart_path));
	
	Conductor.stop();
	dev_songName.text = chartData.song.capitalize() if (chartData != null) else "NO CHART";
	Conductor.play();
	Conductor.pause();
	Conductor.position = 0;
	
	# ---- DEV ----
	dev_timeSlider.max_value = player.stream.get_length();
	dev_song_length = int(player.stream.get_length());
	pass

func _ready() -> void:
	Conductor.player = player;
	
	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	_s = player_strum.note_hit.connect(on_hit_note);
	_s = player_strum.note_miss.connect(on_miss_note);
	
	# ---- DEV
	_s = dev_timeSlider.drag_started.connect(drag_started);
	# ----
	
	load_song("user://Mods/Songs/beat_test/beat_test.json");
	pass

func _process(_delta: float) -> void:
	# ---- DEV ----
	update_dev_menu();
	pass

func _beat_pass(_beat: int) -> void:
	pass

func _step_pass(_beat:int, _fract:int) -> void:
	pass

func _on_tree_exiting() -> void:
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	pass

# -------- TESTING! REMOVE AFTER DEV! --------
var is_dragging:bool = false;
var prev_paused:bool = false;

func drag_started() -> void:
	if Conductor.is_playing:
		prev_paused = false;
		Conductor.pause();
		dev_state.text = "Paused";
		pass
	elif Conductor.is_paused: prev_paused = true;
	is_dragging = true;
	pass

func format_time(seconds:float) -> String:
	return "%d:%02d" % [(floor(seconds) / 60), floor(int(seconds) % 60)];

func update_dev_menu() -> void:
	if !is_dragging: dev_timeSlider.value = Conductor.position;
	dev_timeLabel.text = "[%s / %s]" % [format_time(Conductor.position), format_time(dev_song_length)];
	pass

func _on_time_slider_drag_ended(_value_changed: bool) -> void:
	# Set the position.
	Conductor.set_song_position(dev_timeSlider.value);
	is_dragging = false;
	# Position is updated, so update UI to match.
	dev_timeSlider.value = Conductor.position;
	
	if !prev_paused:
		Conductor.pause();
		dev_state.text = "Playing";
		pass
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
	dev_timeSlider.value = Conductor.position;
	Conductor.stop(true);
	player_strum.reset();
	opp_strum.reset();
	is_dragging = false;
	prev_paused = false;
	dev_state.text = "Stopped";
	dev_timeSlider.value = 0;
	pass


func _on_time_slider_value_changed(value: float) -> void:
	if Conductor.is_playing and !Conductor.is_paused: return;
	Conductor.position = value;
	pass # Replace with function body.


func _on_restart_button_up() -> void:
	Conductor.pause(true);
	for note in player_strum.chart.notes:
		note.visible = true;
	for note in opp_strum.chart.notes:
		note.visible = true;
	
	player_strum.note_visual_reset();
	opp_strum.note_visual_reset();
	print(clampf((1 - (1 + ((Conductor.position - (Conductor.player.stream.get_length())) / Conductor.player.stream.get_length()))), 0.25, 0.75));
	await get_tree().create_tween().tween_property(Conductor, "position", 0, clampf((1 - (1 + ((Conductor.position - (Conductor.player.stream.get_length())) / Conductor.player.stream.get_length()))), 0.25, 0.75)).set_ease(Tween.EASE_IN_OUT).finished;
	Conductor.set_song_position(0); 
	Conductor.pause();
	pass
