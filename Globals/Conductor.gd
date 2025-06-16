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

extends Node

# Signals for when beats pass (4th, 8th, etc.)
signal quarter_passed(beat:int);
signal eighth_passed(beat:int, fract:int);
signal twelth_passed(beat:int, fract:int);
signal sixteenth_passed(beat:int, fract:int);

# Same as above signals but AudioServer.get_output_latency() seconds earlier
# (for audio scheduling)
signal quarter_will_pass(beat:int); # Beat
signal eighth_will_pass(beat:int, fract:int); # 1/2 Step
signal twelth_will_pass(beat:int, fract:int); # 3/4 Step
signal sixteenth_will_pass(beat:int, fract:int); # Step

## The current beat.
@export var curr_beat:float = 0;
@export var curr_beat_without_latency:float = 0;
## Beats per minute for the current song.
@export var bpm:float = 100;
## Flag for status on if the song is playing.
@export var is_playing:bool = false;
## Flag for status on if the song is paused, but not stopped.
@export var is_paused:bool = false;
## The audio offset in milliseconds.
@export var audio_offset_ms:int = 0;
## The video offset in milliseconds.
@export var visual_offset_ms:int = 0;

## Song position in seconds.
var position:float = 0.0;
## Scroll speed modifier.
var scroll_speed:float = 1;
## Scroll speed multiplier, do not touch this!
var _offset_scroll_modifier:int = 100;

## The audio handle for the current song.
@onready var player:AudioStreamPlayer;

# Caching this since getting output latency is expensive.
# This value does not change so looking it up once is fine.
var _cached_latency:float = AudioServer.get_output_latency();
var _num_beats_in_song:int = 0;
var _prev_time_seconds:float = 0;
var _loops:int = 0;
var _quarter_passed_incrementor:BeatIncrementor = BeatIncrementor.new(quarter_passed);
var _eighth_passed_incrementor:BeatIncrementor = BeatIncrementor.new(eighth_passed, 2);
var _twelth_passed_incrementor:BeatIncrementor = BeatIncrementor.new(twelth_passed, 3);
var _sixteenth_passed_incrementor:BeatIncrementor = BeatIncrementor.new(sixteenth_passed, 4);
var _quarter_will_pass_incrementor:BeatIncrementor = BeatIncrementor.new(quarter_will_pass);
var _eighth_will_pass_incrementor:BeatIncrementor = BeatIncrementor.new(eighth_will_pass, 2);
var _twelth_will_pass_incrementor:BeatIncrementor = BeatIncrementor.new(twelth_will_pass, 3);
var _sixteenth_will_pass_incrementor:BeatIncrementor = BeatIncrementor.new(sixteenth_will_pass, 4);

## First run boolean.
var _activated:bool = false;

class BeatIncrementor:
	var _fract_mod:int;
	var _signal:Signal;
	var _last_beat:int = -1;
	var _last_fract:int;
	
	
	func _init(sig:Signal, fract_mod:int = 1) -> void:
		_fract_mod = fract_mod;
		_signal = sig;
		_last_fract = fract_mod - 1;
		pass
	
	
	func increment_to(beat:int, fract:int = 0) -> void:
		while beat > _last_beat or fract > _last_fract:
			_last_fract += 1;
			if _last_fract == _fract_mod:
				_last_beat += 1;
				_last_fract = 0;
				pass
			
			if _fract_mod == 1: _signal.emit(_last_beat);
			else: _signal.emit(_last_beat, _last_fract);
			pass
		pass
	pass

func _ready() -> void:
	pass

func setup() -> void:
	if player == null: return;
	_activated = true;
	_prev_time_seconds = -_cached_latency - 0.001;
	curr_beat = _prev_time_seconds / 60 * bpm;
	_loops = 0;
	_num_beats_in_song = round(player.stream.get_length() / 60 * bpm);
	player.play();
	player.stream_paused = true;
	is_paused = true;
	is_playing = false;
	pass

func play() -> void:
	if player == null: return;
	setup();
	#await get_tree().create_timer(3).timeout;
	player.play();
	is_playing = true;
	pass

## Stops the current song but does not flush variables.
func stop(clear_song:bool = false) -> void:
	if player == null: return;
	player.stop();
	is_playing = false;
	is_paused = false;
	_activated = false;
	if clear_song: setup();
	pass

## Pauses and resumes the song.
## Returns ```is_paused```.
func pause() -> void:
	if player == null: return;
	is_paused = !is_paused;
	is_playing = !is_paused;
	player.stream_paused = is_paused;
	pass

func get_beat_time() -> float:
	return 60 / bpm;

## Set the position of the song in seconds.
func set_song_position(pos:float) -> void:
	player.play(pos)
	player.stream_paused = is_paused;
	await get_tree().process_frame;
	position = (player.get_playback_position() + AudioServer.get_time_since_last_mix() - _cached_latency - audio_offset_ms / 1000.0);
	_prev_time_seconds = position - 1;
	pass

func _process(_delta:float) -> void:
	if player == null: return;
	if not player.playing: is_playing = false;
	if not is_playing or is_paused: return;
	
	var time_seconds:float = (player.get_playback_position() + AudioServer.get_time_since_last_mix() - _cached_latency - audio_offset_ms / 1000.0);
	
	# Validation
	if not _is_valid_update(time_seconds): return;

	position = time_seconds;
	
	if time_seconds - _prev_time_seconds < -5:
		print("big reverse: prev=", _prev_time_seconds, " curr=", time_seconds, " delta=", _prev_time_seconds - time_seconds);
		# Loop happened!
		_loops += 1;
		# Make prev time on the same "loop" as the curr time. It's not
		# recommended to use song length directly as there can be small
		# inaccuracies with audio looping and the song itself
		_prev_time_seconds -= _num_beats_in_song / bpm * 60;
	
	var beat:float = time_seconds / 60 * bpm;
	var prev_beat:float = _prev_time_seconds / 60 * bpm;
	
	# Now add additional beats from previous loops
	beat += _loops * _num_beats_in_song;
	prev_beat += _loops * _num_beats_in_song;
	
	# Apply visual beat offset
	beat -= visual_offset_ms / 60000.0 * bpm;
	prev_beat -= visual_offset_ms / 60000.0 * bpm;
	
	# Signal the beats that are happening (with offset)
	curr_beat = beat
	if floor(beat) > floor(prev_beat):
		_quarter_passed_incrementor.increment_to(floor(beat));
	if floor(beat*2) > floor(prev_beat*2):
		_eighth_passed_incrementor.increment_to(floor(beat), floor((beat - floor(beat)) * 2));
	if floor(beat*3) > floor(prev_beat*3):
		_twelth_passed_incrementor.increment_to(floor(beat), floor((beat - floor(beat)) * 3));
	if floor(beat*4) > floor(prev_beat*4):
		_sixteenth_passed_incrementor.increment_to(floor(beat), floor((beat - floor(beat)) * 4));
	
	# Unapply visual beat offset
	beat += visual_offset_ms / 60000.0 * bpm;
	prev_beat += visual_offset_ms / 60000.0 * bpm;
	
	# Now adjust the time to be in the future
	var latency_in_beats:float = _cached_latency / 60 * bpm;
	beat += latency_in_beats;
	prev_beat += latency_in_beats;
	
	# Signal the beats that will happen soon
	curr_beat_without_latency = beat;
	if floor(beat) > floor(prev_beat):
		_quarter_will_pass_incrementor.increment_to(floor(beat));
	if floor(beat*2) > floor(prev_beat*2):
		_eighth_will_pass_incrementor.increment_to(floor(beat), floor((beat - floor(beat)) * 2));
	if floor(beat*3) > floor(prev_beat*3):
		_twelth_will_pass_incrementor.increment_to(floor(beat), floor((beat - floor(beat)) * 3));
	if floor(beat*4) > floor(prev_beat*4):
		_sixteenth_will_pass_incrementor.increment_to(floor(beat), floor((beat - floor(beat)) * 4));
	
	# Keep track of the previous frame's time.
	_prev_time_seconds = time_seconds;
	pass

## Verifies the update is valid. True if the update is valid.
func _is_valid_update(time_seconds:float) -> bool:
	return (
		# Web issue fix.
		time_seconds < 1000 and (
			# Prevents a backward time jump.
			time_seconds > _prev_time_seconds or
			# Loop happened.
			time_seconds - _prev_time_seconds < -5)
			);
