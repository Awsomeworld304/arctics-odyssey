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
			"left": left.add_child(note);
			"down": down.add_child(note);
			"center": center.add_child(note);
			"up": up.add_child(note);
			"right": right.add_child(note);
		note.position.y = sec_to_px(note);
		pass
	pass

func update_chart() -> void:
	pass

func bot_input() -> void:
	# Input notes.
	for note in chart.notes:
		if note.data.time == Conductor.position:
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

func _process(_delta: float) -> void:
	if not bot_strumline:
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
	else: bot_input();
	
	# Handle AI
	if bot_strumline:
		Input.action_release("bot_left");
		Input.action_release("bot_down");
		Input.action_release("bot_center");
		Input.action_release("bot_up");
		Input.action_release("bot_right");
		pass
	pass


func note_is_in_range(note:Note, hit_time:float) -> bool:
	#print(abs(note.data.time - hit_time));
	return abs(note.data.time - hit_time) <= hit_window;

func calculate_note(note:Note, hit_time:float) -> void:
	#print("Note in range and is hit.");
	var rating:String = "ERROR";
	
	var diff:float = abs(note.data.time - hit_time);
	if diff <= 0.016: rating = "Marvelous";
	elif diff <= 0.032: rating = "Perfect";
	elif diff <= 0.064: rating = "Good";
	elif diff <= 0.128: rating = "Bad";
	else: rating = "What? " + var_to_str(diff);
		
	#ui_RATING.text = rating;
	#ui_RATING.create_tween().stop();
	#ui_RATING.modulate = Color.WHITE;
	
	# Neg if too late, pos if too early.
	#var hit_offset:float = note.data.time - hit_time;
	hit_notes += 1;
	
	##note.queue_free();
	note.visible = false;
	# Rating
	#get_tree().create_tween().tween_property(ui_RATING, "modulate", Color.TRANSPARENT, 0.25);
	pass

# -------- Handler Functions --------
func _check_note_press(note_group:String = "none") -> void:
	for note:Note in get_tree().get_nodes_in_group(note_group) as Array[Note]:
		if note is Note:
			var ht:float = Conductor.position;
			if note_is_in_range(note, ht):
				calculate_note(note, ht);
				pass
			else:
				if note.position.y < (-5*Conductor.scroll_speed): note.visible = false;
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
	if Conductor.player != null:
		Conductor.player = null;
		Conductor.is_paused = false;
		Conductor.is_playing = false;
		pass
	pass
