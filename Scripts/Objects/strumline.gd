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
class_name Strumline

## Set the strumline to AI, ignoring any player input and scoring.
@export var bot_strumline:bool = false;

## The currently loaded chart.
@export var chart:Chart = null;

## How many notes have been hit.
var hit_notes:int = 0;
var hit_window:float = 0.128; # 64ms

@onready var left:Strum = $left as Strum;
@onready var down:Strum = $down as Strum;
@onready var center:Strum = $center as Strum;
@onready var up:Strum = $up as Strum;
@onready var right:Strum = $right as Strum;
@onready var ui_RATING:Label = $Rating as Label; 

signal note_hit(note:Note);
signal note_miss(note:Note);

func _init(is_bot_strumline:bool = false) -> void:
	is_bot_strumline = bot_strumline;
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
		pass
	# Handle instance.
	elif note != null and index == -1:
		pass
	# Handle both.
	elif note != null and index >= 0:
		pass
	else:
		push_error("Strumline -> Remove Note: Can't remove a note without an instance or an index.");
	pass

func load_chart(new_chart:Chart) -> void:
	if Chart.validate_chart(new_chart):
		self.chart = new_chart;
		pass
	else:
		printerr("Chart -> Chart is not valid!");
		return;
		
	# Chart data is parsed, now to calculate the positions of each note.
	for note:Note in self.chart.notes:
		match(note.key_name):
			"left":
				note.add_to_group("bot_left" if bot_strumline else "left");
				left.add_child(note);
			"down":
				note.add_to_group("bot_down" if bot_strumline else "down");
				down.add_child(note);
			"center":
				note.add_to_group("bot_center" if bot_strumline else "center");
				center.add_child(note);
			"up":
				note.add_to_group("bot_up" if bot_strumline else "up");
				up.add_child(note);
			"right":
				note.add_to_group("bot_right" if bot_strumline else "right");
				right.add_child(note);
		note.position.y = sec_to_px(note);
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
	var path:String = chart.chart_path;
	chart = null;
	load_chart(Chart._parse_chart(path));
	pass

func update_chart() -> void:
	pass

func bot_input() -> void:
	if chart == null or chart.notes.size() == 0: return;
	for note:Note in chart.notes:
		if note.visible and note.hit_time == -32 and abs(note.time - Conductor.position) <= 0.016:
			#print("BOT calculate_note called for note at time: ", note.time);
			Input.action_press("bot_" + note.key_name);
			Input.action_release("bot_" + note.key_name);
		pass
	
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
	if bot_strumline:
		left.toggle_bot();
		down.toggle_bot();
		center.toggle_bot();
		up.toggle_bot();
		right.toggle_bot();
		self.set_process_input(false);
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
	var result:bool = abs(note.time - hit_time) <= hit_window;
	note.hit_time = hit_time;
	if !result: note_miss.emit();
	return result;

func calculate_note(note:Note, hit_time:float) -> void:
	#print("Note in range and is hit.");
	var rating:String = "ERROR";
	
	var diff:float = abs(note.time - hit_time);
	if diff <= 0.016: rating = "Marvelous";
	elif diff <= 0.032: rating = "Perfect";
	elif diff <= 0.064: rating = "Good";
	elif diff <= 0.128: rating = "Bad";
	else: rating = "What? " + var_to_str(diff);
		
	ui_RATING.text = rating;
	ui_RATING.create_tween().stop();
	var color:Color = Color.WHITE if !bot_strumline else Color.CRIMSON;
	var tcolor:Color = color;
	tcolor.a = 0;
	ui_RATING.modulate = color;
	
	# Neg if too late, pos if too early.
	#var hit_offset:float = note.time - hit_time;
	if !bot_strumline: hit_notes += 1;
	note_hit.emit(note);
	
	##note.queue_free();
	note.visible = false;
	#note.modulate = Color.TRANSPARENT;
	# Rating
	var _t:PropertyTweener = get_tree().create_tween().tween_property(ui_RATING, "modulate", tcolor, 0.25);
	pass

# -------- Handler Functions --------
func _check_note_press(note_group:StringName = "none") -> void:
	for note:Note in get_tree().get_nodes_in_group(note_group) as Array[Note]:
		if note is Note:
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				calculate_note(note, ht);
				pass
			# Note is not hit.
			else:
				#if note.position.y < (-5*Conductor.scroll_speed): note.visible = false;
				pass
			pass
		pass
	pass

## The bot version of _check_note_press. Makes sure it's only hitting bot notes.
func _bot_note_press(note_group:StringName = "none") -> void:
	for note:Note in get_tree().get_nodes_in_group("bot_" + note_group) as Array[Note]:
		if note is Note and bot_strumline:
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				calculate_note(note, ht);
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
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	pass
