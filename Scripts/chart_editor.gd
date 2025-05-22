extends Node2D

@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;
@onready var s_LEFT:AnimatedSprite2D = $"hud/player/Strumline/left" as AnimatedSprite2D;
@onready var s_DOWN:AnimatedSprite2D = $"hud/player/Strumline/down" as AnimatedSprite2D;
@onready var s_CENTER:AnimatedSprite2D = $"hud/player/Strumline/center" as AnimatedSprite2D;
@onready var s_UP:AnimatedSprite2D = $"hud/player/Strumline/up" as AnimatedSprite2D;
@onready var s_RIGHT:AnimatedSprite2D = $"hud/player/Strumline/right" as AnimatedSprite2D;

@onready var ui_RATING:Label = $"hud/Rating" as Label;

## How many notes have been hit.
var hit_notes:int = 0;
var hit_window:float = 0.128; # 64ms

func sec_to_px(note:Note) -> int:
	return note.data.time * (Conductor.bpm/60) * Conductor.scroll_speed;

func _enter_tree() -> void:
	pass

func _ready() -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
	#DisplayServer.window_set_size(Vector2i(640*2, 360*2), 0);
	#await get_tree().create_timer(0.1).timeout;
	#DisplayServer.window_set_title("Chart Editor - " + (ProjectSettings.get_setting("application/config/name") as String));
	#DisplayServer.window_set_position(Vector2i(1920,320), 0);
	ui_RATING.modulate = Color.TRANSPARENT;
	Conductor.player = player;
	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	
	for i in range(64):
		var note:Note = Note.new();
		note.key_name = "left";
		note.add_to_group("left");
		s_LEFT.add_child(note);
		note.position.x = 0;
		note.position.y = (100 * i) + 100;
		note.data.time = ((note.position.y / Conductor.scroll_speed)/(Conductor.bpm/60));
		pass
	
	for i in range(64):
		var note:Note = Note.new();
		note.key_name = "up";
		note.add_to_group("up");
		s_UP.add_child(note);
		note.position.x = 0;
		note.position.y = (100 * i) + 150;
		note.data.time = ((note.position.y / Conductor.scroll_speed)/(Conductor.bpm/60));
		pass

	var chartData:Chart = Chart.new("res://Assets/Songs/beat_test/beat_test.json");
	print(chartData.notes);
	
	"""
	# Chart data is parsed, now to calculate the positions of each note.
	for note in chartData.notes:
		
		match(note.key_name):
			"left": s_LEFT.add_child(note);
			"down": s_DOWN.add_child(note);
			"center": s_CENTER.add_child(note);
			"up": s_UP.add_child(note);
			"right": s_RIGHT.add_child(note);
			
		note.position.y = sec_to_px(note);
		pass
	"""
	Conductor.play();
	pass

func note_is_in_range(note:Note, hit_time:float) -> bool:
	#print(abs(note.data.time - hit_time));
	return abs(note.data.time - hit_time) <= hit_window;



func calculate_note(note:Note, hit_time:float) -> void:
	#print("Note in range and is hit.");
	var rating:String = "ERROR";
	
	var diff = abs(note.data.time - hit_time)
	if diff <= 0.016: rating = "Marvelous";
	elif diff <= 0.032: rating = "Perfect";
	elif diff <= 0.064: rating = "Good";
	elif diff <= 0.128: rating = "Bad";
	else: rating = "What? " + var_to_str(diff);
		
	ui_RATING.text = rating;
	ui_RATING.create_tween().stop();
	ui_RATING.modulate = Color.WHITE;
	
	# Neg if too late, pos if too early.
	#var hit_offset:float = note.data.time - hit_time;
	hit_notes += 1;
	
	note.queue_free();
	# Rating
	get_tree().create_tween().tween_property(ui_RATING, "modulate", Color.TRANSPARENT, 0.25);
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
	text += "Prev. time (sec): " + var_to_str(Conductor._prev_time_seconds) + "\n";
	text += "Position (sec): " + var_to_str(Conductor.position) + "\n";
	text += "Hit Notes: " + var_to_str(hit_notes) + "\n";
	($"main/debuginfo" as RichTextLabel).text = text;
	pass

var text:String = "";
func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug2"): Conductor.pause();
	_song_info();
	# Handle note inputs.
	if Input.is_action_just_pressed("left"):
		_left_pressed();
		pass
	if Input.is_action_just_pressed("down"):
		_down_pressed();
		pass
	if Input.is_action_just_pressed("center"):
		_center_pressed();
		pass
	if Input.is_action_just_pressed("up"):
		_up_pressed();
		pass
	if Input.is_action_just_pressed("right"):
		_right_pressed();
		pass
	pass


func _beat_pass(beat: int) -> void:
	total_beat = beat;
	pass

func _step_pass(beat:int, fract:int) -> void:
	total_fract = fract;
	pass

# -- Handler Functions --
func _check_note_press(note_group:String = "none") -> void:
	for note in get_tree().get_nodes_in_group(note_group):
		if note is Note:
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				calculate_note(note, ht);
				pass
			else:
				if note.position.y < -5: get_tree().create_tween().tween_property(note, "modulate", Color.TRANSPARENT, 0.01);
				pass
			pass
		pass
	pass

func _left_pressed() -> void: 
	_check_note_press("left");
	pass
func _down_pressed() -> void:
	_check_note_press("down");
	pass
func _center_pressed() -> void:
	_check_note_press("center");
	pass
func _up_pressed() -> void:
	_check_note_press("up");
	pass
func _right_pressed() -> void:
	_check_note_press("right");
	pass


func _on_tree_exiting() -> void:
	Conductor.player = null;
	Conductor.is_paused = false;
	Conductor.is_playing = false;
	pass
