extends Node2D

@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;
@onready var strum:Strumline = $"hud/player/Strumline" as Strumline;
"""
@onready var s_LEFT:AnimatedSprite2D = $"hud/player/Strumline/left" as AnimatedSprite2D;
@onready var s_DOWN:AnimatedSprite2D = $"hud/player/Strumline/down" as AnimatedSprite2D;
@onready var s_CENTER:AnimatedSprite2D = $"hud/player/Strumline/center" as AnimatedSprite2D;
@onready var s_UP:AnimatedSprite2D = $"hud/player/Strumline/up" as AnimatedSprite2D;
@onready var s_RIGHT:AnimatedSprite2D = $"hud/player/Strumline/right" as AnimatedSprite2D;
"""
@onready var ui_RATING:Label = $"hud/Rating" as Label;

## How many notes have been hit.
var hit_notes:int = 0;
var hit_window:float = 0.128; # 64ms

func sec_to_px(note:Note) -> float:
	return note.data.time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func px_to_sec(px:float) -> float:
	return px / (Conductor.bpm/60) / (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func beat_to_sec(beats: float) -> float:
	return (beats * 60.0) / Conductor.bpm;


func _enter_tree() -> void:
	pass

func on_hit_note(note:Note) -> void:
	pass

func _ready() -> void:
	#strum.bot_strumline = true;
	ui_RATING.modulate = Color.TRANSPARENT;
	Conductor.player = player;
	
	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	strum.note_hit.connect(on_hit_note);
	
	var chartData:Chart = Chart.new();
	
	chartData = chartData._parse_chart("user://Mods/Songs/beat_test/beat_test.json");
	strum.load_chart(chartData);
	print(chartData.notes);
	
	Conductor.play();
	Conductor.pause();
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
