extends Node2D

const err_msg_template:String = "An error has occured while loading the chart: %s\n%s\n\nIn mod:\n%s\n\nThe default chart has been loaded.\nIf this keeps happening, your chart is most likley corrupted.";

# Strumline Stuff
@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;
@onready var strum:EditorStrumline = $"hud/player/Strumline" as EditorStrumline;
@onready var ui_RATING:RichTextLabel = $"hud/player/Strumline/Rating" as RichTextLabel;

# UI Stuff
@onready var songName:Label = $main/ChartMenu/Chart/ChartName as Label;
@onready var editorGrid:GridPanel = $"hud/player/Strumline/GridPanel" as GridPanel;
@onready var errBox:ConfirmationDialog = $main/ErrorPopup as ConfirmationDialog;
@onready var errTxt:Label = $main/ErrorPopup/ErrTxt as Label;

## How many notes have been hit.
var hit_notes:int = 0;

## Path to current chart.
var current_chart:String = "";

var note_zoom:int = 1;

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

func new_chart() -> void:
	var chartData:Chart = Chart.new();
	pass

func load_song(chart_path:String) -> Error:
	var chartData:Chart = Chart.new();
	chartData = Chart._parse_chart(chart_path);
	if chartData == null: return Error.ERR_FILE_CANT_READ;
	
	Conductor.bpm = chartData.song_bpm;
	Conductor.scroll_speed = chartData.note_speed;
	Conductor.curr_time_signature = chartData.time_signature;
	
	($main/ChartMenu/Chart/NoteSpeedBox as SpinBox).value = Conductor.scroll_speed;
	
	strum.strumline_id = &"edit";
	strum.ui_SLID.text = "SLID: edit";
	strum.reset();
	
	var err:Error = strum.load_chart(chartData);
	Conductor.stop();
	if err != Error.OK: return err;
	songName.text = chartData.song.capitalize();
	
	Conductor.play();
	Conductor.pause();
	Conductor.position = 0;

	editorGrid.update_grid_size(note_zoom);
	timeSlider.max_value = player.stream.get_length();
	return Error.OK;

#???? :sob:
func spawn_stage() -> void:
	pass

func _ready() -> void:
	#strum.bot_strumline = true;
	#var audio:AudioStreamMP3 = AudioStreamMP3.load_from_file("user://Mods/Songs/expurgation/expurgation.mp3");
	#	player.stream = audio;
	
	Conductor.player = player;

	var _s:int = Conductor.sixteenth_will_pass.connect(_step_pass);
	_s = Conductor.quarter_will_pass.connect(_beat_pass);
	_s = strum.note_hit.connect(on_hit_note);
	_s = timeSlider.drag_started.connect(drag_started);
	
	if load_song("user://Mods/Songs/beat_test/beat_test.json") != OK:
		errBox.visible = true;
		errTxt.text = err_msg_template % ["Beat Test", "user://Mods/Songs/beat_test/beat_test.json", "???"];
		pass
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
	timeLabel.text = "[%s / %s]" % [format_time(Conductor.position), format_time(int(0.0 if !player.stream else player.stream.get_length()))];
	pass

func _beat_pass(beat: int) -> void:
	total_beat = beat;
	pass

func _step_pass(_beat:int, fract:int) -> void:
	total_fract = fract;
	pass

func _on_tree_exiting() -> void:
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if Conductor.is_playing: return;
			Conductor.set_song_position(Conductor.position + (0.1 * strum.chart.note_speed))
			pass
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if Conductor.is_playing: return;
			Conductor.set_song_position(Conductor.position + (-0.1 * strum.chart.note_speed))
			pass
	pass

#region UI - Chart
@onready var timeSlider:HSlider = $main/_TimeSliderBG/TimeSlider as HSlider;
@onready var timeLabel:Label = $main/_TimeSliderBG/_TimeSliderTitleBG/SongTime as Label;
@onready var sliderAnim:AnimationPlayer = $main/_TimeSliderBG/TimeSliderAnim as AnimationPlayer;
@onready var sliderMini:Button = $main/_TimeSliderBG/_TimeSliderTitleBG/SliderMinim as Button;

func _on_slider_minim_button_up() -> void:
	if sliderMini.text == "-": sliderAnim.play("slide");
	else: sliderAnim.play_backwards("slide");
	
	if sliderMini.text == "-": sliderMini.text = "+";
	else: sliderMini.text = "-";
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

func _on_stop_chart_button_up() -> void:
	timeSlider.value = Conductor.position;
	Conductor.stop(true);
	strum.reset_notes();
	timeSlider_is_dragging = false;
	timeSlider_prev_paused = false;
	timeSlider.value = 0;
	pass

func _on_play_chart_button_up() -> void:
	Conductor.pause();
	pass

func _on_reload_chart_button_up() -> void:
	load_song(strum.chart.chart_path);
	pass

func _on_time_slider_value_changed(value: float) -> void:
	if Conductor.is_playing and !Conductor.is_paused: return;
	Conductor.position = value;
	pass

func _on_note_speed_box_value_changed(value: float) -> void:
	Conductor.scroll_speed = value;
	if strum.chart: strum.chart.note_speed = Conductor.scroll_speed;
	pass

#endregion

#region UI - Note
@onready var plus:TextureButton = $main/ChartMenu/Note/PlusZoom as TextureButton;
@onready var minus:TextureButton = $main/ChartMenu/Note/MinusZoom as TextureButton;
@onready var zlbl:Label = $main/ChartMenu/Note/ZoomLabel as Label;

func set_zoom_label() -> void:
	zlbl.text = "Zoom 1/%s" % (note_zoom * 4);
	pass

func _on_plus_zoom_button_up() -> void:
	minus.disabled = (note_zoom == 1);
	plus.disabled = (note_zoom == 32);
	match note_zoom:
		1: note_zoom = 2;
		2: note_zoom = 4;
		4: note_zoom = 8;
		8: note_zoom = 16;
		16: note_zoom = 32;
		_: pass
	minus.disabled = (note_zoom == 1);
	plus.disabled = (note_zoom == 32);
	set_zoom_label();
	
	editorGrid.update_grid_size(note_zoom);
	pass

func _on_minus_zoom_button_up() -> void:
	plus.disabled = (note_zoom == 32);
	minus.disabled = (note_zoom == 1);
	match note_zoom:
		2: note_zoom = 1;
		4: note_zoom = 2;
		8: note_zoom = 4;
		16: note_zoom = 8;
		32: note_zoom = 16;
		_: pass
	plus.disabled = (note_zoom == 32);
	minus.disabled = (note_zoom == 1);
	set_zoom_label();
	
	editorGrid.update_grid_size(note_zoom);
	pass

func _on_minus_zoom_mouse_exited() -> void:
	minus.release_focus();
	pass

func _on_plus_zoom_mouse_exited() -> void:
	plus.release_focus();
	pass
#endregion
