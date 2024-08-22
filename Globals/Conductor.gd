# Copyright (C) 2024 JamesTech4849
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

var songPosition: float = 0.0;
var bpm: float = 100.0;
var speed: float = 1.0;

var timeBetweenBeats: float = ((60.0 / bpm) * 1000.0);
var timeBetweenSteps: float = timeBetweenBeats / 4.0;

var curBeat: int = 0;
var curStep: int = 0;

var curBeat_f: float = 0.0;
var curStep_f: float = 0.0;

# MS of allowed safe frames.
var safeZoneOffset: float = 166.6;

# funny array of [position_in_song, bpm, step_change_is_at]
var bpm_changes: Array = [];

signal beat_hit;
signal step_hit;

func _process(_delta: float) -> void:
	var oldBeat: int = curBeat;
	var oldStep: int = curStep;

	var lastChange: Array = [0, 0, 0];
	
	for change in bpm_changes:
		if songPosition >= change[0]:
			lastChange = change;
			
			bpm = change[1];
			recalculate_values();
		else:
			break;
	
	if len(lastChange) < 3:
		lastChange.append(0);
	
	curStep_f = lastChange[2] + ((songPosition - lastChange[0]) / timeBetweenSteps);
	curBeat_f = curStep_f / 4.0;
	
	curStep = lastChange[2] + floor((songPosition - lastChange[0]) / timeBetweenSteps);
	curBeat = floor(curStep / 4.0);
	
	if curStep != oldStep and curStep > oldStep:
		step_hit.emit();
	if curBeat != oldBeat and curBeat > oldBeat:
		beat_hit.emit();

func recalculate_values() -> void:
	timeBetweenBeats = ((60.0 / bpm) * 1000.0);
	timeBetweenSteps = timeBetweenBeats / 4.0;

func change_bpm(new_bpm, changes = []):
	if len(changes) == 0:
		changes = [[0.0, new_bpm, 0.0]];
	
	bpm_changes = changes;
	bpm = new_bpm;
	recalculate_values();

func map_bpm_changes(songData) -> Array:
	var changes: Array = [];
	
	var cur_bpm: float = songData["bpm"];
	var total_steps: int = 0;
	var total_pos: float = 0.0;
	
	for section in songData["notes"]:
		if "changeBPM" in section:
			if section["changeBPM"] and section["bpm"] != cur_bpm and section["bpm"] > 0:
				cur_bpm = section["bpm"];
				var change = [total_pos, section["bpm"], total_steps];
				changes.append(change);
		
		if not "lengthInSteps" in section:
			section["lengthInSteps"] = 16;
		
		var section_length:int = section["lengthInSteps"];
		
		total_steps += section_length;
		total_pos += ((60.0 / cur_bpm) * 1000.0 / 4.0) * section_length;
	
	return changes;
