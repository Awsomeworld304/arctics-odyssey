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

@onready var left:AnimatedSprite2D = $left as AnimatedSprite2D;
@onready var down:AnimatedSprite2D = $down as AnimatedSprite2D;
@onready var center:AnimatedSprite2D = $center as AnimatedSprite2D;
@onready var up:AnimatedSprite2D = $up as AnimatedSprite2D;
@onready var right:AnimatedSprite2D = $right as AnimatedSprite2D;
@onready var ui_RATING:Label = $Rating as Label; 

signal note_hit(note:Note);
signal note_miss(note:Note);

func sec_to_px(note:Note) -> float:
	return note.time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func px_to_sec(px:float) -> float:
	return px / (Conductor.bpm/60) / (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func beat_to_sec(beats: float) -> float:
	return (beats * 60.0) / Conductor.bpm;

func add_note(note:Note) -> void:
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

func load_chart(chart:Chart) -> void:
	if Chart.validate_chart(chart):
		self.chart = chart;
		pass
	else:
		printerr("Chart -> Chart is not valid!");
		return;
		
	# Chart data is parsed, now to calculate the positions of each note.
	for note in self.chart.notes:
		match(note.key_name):
			"left":
				note.add_to_group("left");
				left.add_child(note);
			"down":
				note.add_to_group("down");
				down.add_child(note);
			"center":
				note.add_to_group("center");
				center.add_child(note);
			"up":
				note.add_to_group("up");
				up.add_child(note);
			"right":
				note.add_to_group("right");
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
	chart = null;
	pass

func update_chart() -> void:
	pass

func bot_input() -> void:
	# Input notes.
	for note:Note in chart.notes:
		if note.time == Conductor.position:
			print("Bot hitting note %s at %s" % [note.key_name, Conductor.position]);
			Input.action_press("bot_" + note.key_name);
			pass
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
	pass

func _input(event: InputEvent) -> void:
	if bot_strumline:
		Input.action_release("bot_left");
		Input.action_release("bot_down");
		Input.action_release("bot_center");
		Input.action_release("bot_up");
		Input.action_release("bot_right");
		return;

	# Player Input
	if event.is_action_pressed("left"): _left_pressed();
	if event.is_action_pressed("down"): _down_pressed();
	if event.is_action_pressed("center"): _center_pressed();
	if event.is_action_pressed("up"): _up_pressed();
	if event.is_action_pressed("right"): _right_pressed();
	pass

func _process(_delta: float) -> void:
	if bot_strumline: bot_input();
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
	ui_RATING.modulate = Color.WHITE;
	
	# Neg if too late, pos if too early.
	#var hit_offset:float = note.time - hit_time;
	hit_notes += 1;
	
	note_hit.emit(note);
	
	##note.queue_free();
	note.visible = false;
	#note.modulate = Color.TRANSPARENT;
	# Rating
	get_tree().create_tween().tween_property(ui_RATING, "modulate", Color.TRANSPARENT, 0.25);
	pass

# -------- Handler Functions --------
func _check_note_press(note_group:String = "none") -> void:
	for note:Note in get_tree().get_nodes_in_group(note_group) as Array[Note]:
		if note is Note:
			print("Possible note hit.");
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				calculate_note(note, ht);
				pass
			else:
				#if note.position.y < (-5*Conductor.scroll_speed): note.visible = false;
				pass
			pass
		else: print("found thing that is not a note. %s" % note);
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
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	pass
