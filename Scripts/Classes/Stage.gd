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

func on_hit_note(_note:Note) -> void:
	#print("Stage -> Hit Note");
	phealth += 5;
	pass

var phealth:int = 100;
func on_miss_note(_note:Note) -> void:
	if Settings.debug: print("Stage -> Miss Note");
	phealth -= 5;
	get_tree().create_tween().tween_property(player_health, "value", phealth, 0.2).from_current();
	pass

var chartData:Chart;
func load_song(chart_path:String) -> void:
	chartData = Chart.new();
	chartData = Chart._parse_chart(chart_path);
	chartData.chart_path = chart_path;
	
	Conductor.bpm = chartData.song_bpm if (chartData != null) else 100;
	Conductor.scroll_speed = chartData.note_speed if (chartData != null) else 1;
	
	player_strum.load_chart(chartData);
	opp_strum.load_chart(Chart._parse_chart(chart_path));
	
	Conductor.stop();
	Conductor.play();
	Conductor.pause();
	Conductor.position = 0;
	pass

func _ready() -> void:
	var audio:AudioStreamMP3 = AudioStreamMP3.load_from_file("user://Mods/Songs/expurgation/expurgation.mp3");
	player.stream = audio;
	
	Conductor.player = player;
	
	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	_s = player_strum.note_hit.connect(on_hit_note);
	_s = player_strum.note_miss.connect(on_miss_note);
	
	load_song("user://Mods/Songs/expurgation/expurgation.json");
	pass

func _process(_delta: float) -> void:
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
