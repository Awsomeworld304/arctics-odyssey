# Copyright (C) 2024 - 2025 JamesTech4849
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

extends Node2D
class_name EditorStrumline

"""
A note about the strumline, to access any child group, use its ID.
It's usually in a format like this ```xxxx.{your_group}```.
The ID is 4 characters long. (a-f)(0-9).
"""

## Set the strumline to AI, ignoring any player input and scoring.
@export var bot_strumline:bool = false;

## The currently loaded chart.
@export var chart:Chart = null;

## The strumline ID.
@export var strumline_id:StringName = &"";

## How many notes have been hit.
var hit_notes:int = 0;

## The timing window of each note.
var hit_window:float = 0.128; # 64ms

@onready var left:Strum = $left as Strum;
@onready var down:Strum = $down as Strum;
@onready var center:Strum = $center as Strum;
@onready var up:Strum = $up as Strum;
@onready var right:Strum = $right as Strum;

@onready var ui_RATING:RichTextLabel = $Rating as RichTextLabel;
@onready var ui_SLID:Label = $slidLabel as Label;

signal note_hit(note:Note);
signal note_miss(note:Note);

var strumline_bit_pile:PackedStringArray = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'];
## Generates a new StrumLine ID in the form of a StringName.
func generate_strumline_id() -> StringName:
	var new_id:String = "";
	for _i:int in range(4):
		new_id += strumline_bit_pile[randi_range(0, strumline_bit_pile.size()-1)];
		pass
	if Settings.debug: print("Strumline -> GSLID: New ID: %s" % new_id);
	return StringName(new_id);

func _init(is_bot_strumline:bool = false, in_editor:bool = false) -> void:
	self.bot_strumline = is_bot_strumline;
	self.strumline_id = generate_strumline_id() if !in_editor else &"edit";
	pass

func _enter_tree() -> void:
	if self.strumline_id == "edit": return;
	if get_tree().has_group(&"strumline"):
		for strum:Strumline in (get_tree().get_nodes_in_group("strumline") as Array[Strumline]):
			if !(strum is Strumline): return;
			if self.strumline_id == strum.strumline_id: self.strumline_id = generate_strumline_id();
			pass
		pass
	self.add_to_group("strumline");
	pass

func sec_to_px(note:Note) -> float:
	return note.time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func px_to_sec(px:float) -> float:
	return px / (Conductor.bpm/60) / (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func beat_to_sec(beats: float) -> float:
	return (beats * 60.0) / Conductor.bpm;

func add_note(_note:Note) -> void:
	pass

func remove_note(note:Note = null, index:int = -1) -> void:
	# Handle index.
	if note == null and index >= 0:
		for i:int in len(self.chart.notes):
			if i == index: self.chart.notes[i].queue_free();
			pass
		pass
	# Handle instance.
	elif note != null and index == -1:
		for known_note:Note in self.chart.notes:
			if known_note == note: known_note.queue_free();
			pass
		pass
	# Handle both.
	elif note != null and index >= 0:
		for i:int in len(self.chart.notes):
			if index == i and note == self.chart.notes[i]:
				self.chart.notes[i].queue_free();
				pass
			pass
		pass
	# No note or index.
	else:
		push_error("Strumline -> Remove Note: Can't remove a note without an instance or an index.");
		pass
	pass

func load_chart(new_chart:Chart) -> Error:
	var _chart_error:Error = Chart.validate_chart(new_chart);
	if _chart_error == 0:
		self.chart = new_chart;
		pass
	else:
		printerr("Chart -> Chart is not valid!");
		return _chart_error;

	# Chart data is parsed, now to calculate the positions of each note.
	for note:Note in self.chart.notes:
		if bot_strumline: note.add_to_group(strumline_id + ".bot_note");
		else:
			note.add_to_group(strumline_id + ".note");
			note.miss_note.connect(note_miss.emit);
			pass
		
		match(note.key_name):
			"left":
				note.add_to_group((strumline_id + ".bot_left") if bot_strumline else (strumline_id + ".left"));
				left.add_child(note);
			"down":
				note.add_to_group((strumline_id + ".bot_down") if bot_strumline else (strumline_id + ".down"));
				down.add_child(note);
			"center":
				note.add_to_group((strumline_id + ".bot_center") if bot_strumline else (strumline_id + ".center"));
				center.add_child(note);
			"up":
				note.add_to_group((strumline_id + ".bot_up") if bot_strumline else (strumline_id + ".up"));
				up.add_child(note);
			"right":
				note.add_to_group((strumline_id + ".bot_right") if bot_strumline else (strumline_id + ".right"));
				right.add_child(note);
				
		note.position.y = sec_to_px(note);
		note.set_note_skin("note-new");
		note.add_hold();
		pass
		
	return Error.OK;

## TODO: make a soft reset that removes hit times of each note and reverses them with delta
func note_visual_reset() -> void:
	reset_notes();
	pass

## Reset notes back to their initial state without removing them.
## Note: this does not change the note positions nor their timing.
func reset_notes() -> void:
	if bot_strumline:
		for note:Note in get_tree().get_nodes_in_group(strumline_id + ".bot_note") as Array[Note]:
			if !(note is Note): return;
			note.hit_time = -32;
			pass
		pass
	else:
		for note:Note in get_tree().get_nodes_in_group(strumline_id + ".note") as Array[Note]:
			if !(note is Note): return;
			note.hit_time = -32;
			pass
		pass
	pass

## Resets the strumline back to default.
## Warning: This removes the current loaded chart.
func reset() -> void:
	hit_notes = 0;
	for note:Note in left.get_children() as Array[Note]:
		if note is Note: note.queue_free();
		pass
	for note:Note in down.get_children() as Array[Note]:
		if note is Note: note.queue_free();
		pass
	for note:Note in center.get_children() as Array[Note]:
		if note is Note: note.queue_free();
		pass
	for note:Note in up.get_children() as Array[Note]:
		if note is Note: note.queue_free();
		pass
	for note:Note in right.get_children() as Array[Note]:
		if note is Note: note.queue_free();
		pass
	var path:String = chart.chart_path if (chart != null) else "";
	chart = null;
	load_chart(Chart._parse_chart(path));
	pass

func update_chart() -> void:
	pass

func bot_input() -> void:
	if chart == null or chart.notes.size() == 0: return;
	for note:Note in chart.notes:
		if note.visible and note.hit_time == -32 and abs(note.time - Conductor.position) <= 0.016:
			print("BOT calculate_note called for note at time: ", note.time);
			Input.action_press("bot_" + note.key_name);
			Input.action_release("bot_" + note.key_name);
		pass
	print("BOT actuially pressing");

	# Detect note presses.
	if Input.is_action_just_pressed("bot_left"):
		_left_pressed();
		pass
	if Input.is_action_just_pressed("bot_down"):
		_down_pressed();
		pass
	if Input.is_action_just_pressed("bot_center"):
		_center_pressed();
		pass
	if Input.is_action_just_pressed("bot_up"):
		_up_pressed();
		pass
	if Input.is_action_just_pressed("bot_right"):
		_right_pressed();
		pass
	pass

func _ready() -> void:
	ui_RATING.modulate = Color.TRANSPARENT;
	if Settings.debug:
		ui_SLID.visible = true;
		ui_SLID.text = "SLID: " + strumline_id;
		pass
	else: ui_SLID.visible = false;
		
	if bot_strumline:
		left.toggle_bot();
		down.toggle_bot();
		center.toggle_bot();
		up.toggle_bot();
		right.toggle_bot();
		self.set_process_input(false);
		pass
	pass

func _input(event: InputEvent) -> void:
	# Player Input
	if event.is_action_pressed("left"): _left_pressed();
	if event.is_action_pressed("down"): _down_pressed();
	if event.is_action_pressed("center"): _center_pressed();
	if event.is_action_pressed("up"): _up_pressed();
	if event.is_action_pressed("right"): _right_pressed();
	pass

func _process(_delta: float) -> void:
	if bot_strumline and Conductor.is_playing: bot_input();
	pass

func note_is_in_range(note:Note, hit_time:float) -> bool:
	if !note.visible: return false;
	var result:bool = abs(note.time - hit_time) <= hit_window;
	note.hit_time = hit_time;
	if !result: note_miss.emit();
	return result;

var _t:Tween;
func calculate_note(note:Note, hit_time:float) -> void:
	#print("Note in range and is hit.");
	var rating:String = "ERROR";

	var diff:float = abs(note.time - hit_time);
	if diff   <= 0.016: rating = "Marvelous";
	elif diff <= 0.032: rating = "Perfect";
	elif diff <= 0.064: rating = "Good";
	elif diff <= 0.128: rating = "Bad";
	else: rating = "What?\n" + var_to_str(diff); # Should NOT be able to hit this.
	
	if Settings.debug: rating += "\n[font_size=16]%s MS[/font_size]" % int((note.time - hit_time) * 1000);
	ui_RATING.text = rating;
	if _t: _t.kill();
	var color:Color = Color.WHITE if !bot_strumline else Color.CRIMSON;
	var tcolor:Color = color.clamp(Color(0,0,0,0), Color(1,1,1,0));
	ui_RATING.modulate = color;

	if !bot_strumline: hit_notes += 1;
	note_hit.emit(note);
	#note.visible = false;

	# Rating
	_t = get_tree().create_tween();
	_t.tween_property(ui_RATING, "modulate", tcolor, 0.25);
	pass

# -------- Handler Functions --------
func _check_note_press(note_group:StringName = "none") -> void:
	for note:Note in get_tree().get_nodes_in_group(("%s.%s" % [strumline_id, note_group])) as Array[Note]:
		if note is Note:
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				($Hitsound as AudioStreamPlayer).play();
				calculate_note(note, ht);
				pass
			# Note is not hit.
			else:
				if note.position.y < (-5*Conductor.scroll_speed): print("Strumline -> Did press! Missed note?");
				pass
			pass
		pass
	pass

## The bot version of _check_note_press. Makes sure it's only hitting bot notes.
func _bot_note_press(note_group:StringName = "none") -> void:
	for note:Note in get_tree().get_nodes_in_group((strumline_id + ".bot_" + note_group)) as Array[Note]:
		if note is Note and bot_strumline:
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				calculate_note(note, ht);
				pass
			else:
				if note.position.y < (-5*Conductor.scroll_speed): print("Strumline -> BOT Missed note?");
				pass
			pass
		pass
	pass

func _left_pressed() -> void:
	if bot_strumline: _bot_note_press("left");
	else: _check_note_press("left");
	pass
func _down_pressed() -> void:
	if bot_strumline: _bot_note_press("down");
	else: _check_note_press("down");
	pass
func _center_pressed() -> void:
	if bot_strumline: _bot_note_press("center");
	else: _check_note_press("center");
	pass
func _up_pressed() -> void:
	if bot_strumline: _bot_note_press("up");
	else: _check_note_press("up");
	pass
func _right_pressed() -> void:
	if bot_strumline: _bot_note_press("right");
	else: _check_note_press("right");
	pass

func _on_tree_exiting() -> void:
	self.remove_from_group("strumline");
	"""
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	"""
	pass
