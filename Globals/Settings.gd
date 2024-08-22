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

# Static Stuff
var save_file = "user://GRT/EngineSettings.grt";
var mod_file = "user://GRT/ModSettings.grt";
var save_dir = "user://GRT/";

'''
- Encryption Seed:
 - Changes with each update,
 - prev saves will be read-only and converted to new saves if needed.
 - This is not needed, but you can use it if wanted.
'''
var secret = 0;

var debug = true;
var first_run = false;

# Error Stuff
var errorCode = 0;
var errormsg = "";

# Graphics
# windowed, borderless windowed, fullscreen, ex. fullscreen.
var fullscreen_mode = 2;
var resolutions  = [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1920, 1080)];
var resolution_mode = 3;
var fps_options = [30, 60, 120, 140, 144];
var fps_mode = fps_options[1]; # Default is 60 FPS.

# Gameplay
# 0 - 5 | Story mode.
var story_mode = 0;
var story = "MOD";

# Audio
var volume = 100.0; # Master
var musicVolume = 100.0;
var sfxVolume = 100.0;

# Multiplayer
var coopHUDSize = 1.0;
var coopMode = false;

func _save_settings():
	# Setup Save
	var save_items = {
		"key" : secret,
		"fullscreen_mode" : fullscreen_mode,
		"resolution_mode" : resolution_mode,
		"master_volume" : volume,
		"music_volume" : musicVolume,
		"sfx_volume" : sfxVolume,
		"story" : story_mode,
		"coop_mode" : coopMode,
		"coop_hud_size" : coopHUDSize,
		"fps_mode" : fps_mode
	};
	# Save to File
	if !DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir);
	var save_write = FileAccess.open(save_file, FileAccess.WRITE);
	var json_string = JSON.stringify(save_items);
	save_write.store_line(json_string);
	save_write.close();
	pass

func _load_settings() -> Error:
	# Load Data from File
	if not FileAccess.file_exists(save_file):
		if debug:
			first_run = true;
			push_warning("Settings -> Load Settings: No save to load!");
			print_debug("Settings -> Load Settings: Loading default values!");
	var save_read = FileAccess.open(save_file, FileAccess.READ);
	if save_read != null:
		while save_read.get_position() < save_read.get_length():
			var json_pstring = save_read.get_line();

			# Creates the helper class to interact with JSON
			var json = JSON.new();

			# Check if there is any error while parsing the JSON string, skip in case of failure
			var parse_result = json.parse(json_pstring);
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
				LevelManager.errCode = parse_result 
				
				return parse_result;
			var parsed_data = json.get_data();
			
			# Check if save is valid!
			if parsed_data["key"] != secret:
				# Save file has been messed up?
				#get_tree().change_scene_to_file("res://Scenes/Error.tscn"); Not good, use LvlMgr
				LevelManager.error();
			else:
				parsed_data["fullscreen_mode"] = fullscreen_mode;
				parsed_data["resolution_mode"] = resolution_mode;
				parsed_data["volume"] = volume;
				parsed_data["music_volume"] = musicVolume;
				parsed_data["sfx_volume"] = sfxVolume;
				parsed_data["story"] = story_mode;
				parsed_data["coopMode"] = coopMode;
				parsed_data["coopHUDSize"] = coopHUDSize;
				parsed_data["fps_mode"] = fps_mode;
				if debug:
					print(fullscreen_mode, resolution_mode, volume, story_mode, coopMode, coopHUDSize, fps_mode);
	return OK;

func _load_mod_settings():
	# Load Data from File
	if not FileAccess.file_exists(mod_file):
		if debug:
			push_warning("Settings -> Load Settings: No save to load!");
			print_debug("Settings -> Load Settings: Loading default values!");
	var save_read = FileAccess.open(mod_file, FileAccess.READ);
	if save_read != null:
		while save_read.get_position() < save_read.get_length():
			var json_pstring = save_read.get_line();

			# Creates the helper class to interact with JSON
			var json = JSON.new();

			# Check if there is any error while parsing the JSON string, skip in case of failure
			var parse_result = json.parse(json_pstring);
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
				continue;
			var parsed_data = json.get_data();
			
			# Check if save is valid!
			if parsed_data["key"] != secret:
				#save_read = FileAccess.open(save_file, FileAccess.WRITE);
				#save_read.store_line("{\"Save_Error\"}");
				#save_read.close();
				# File Error?
				get_tree().change_scene_to_file("res://Scenes/Error.tscn");
			else:
				parsed_data["fullscreen_mode"] = fullscreen_mode;
				parsed_data["resolution_mode"] = resolution_mode;
				parsed_data["volume"] = volume;
				parsed_data["music_volume"] = musicVolume;
				parsed_data["sfx_volume"] = sfxVolume;
				parsed_data["story"] = story_mode;
				parsed_data["coopMode"] = coopMode;
				parsed_data["coopHUDSize"] = coopHUDSize;
				parsed_data["fps_mode"] = fps_mode;
				if debug:
					print_debug(fullscreen_mode, resolution_mode, volume, story_mode, coopMode, coopHUDSize);
	#  Init Data.
	match resolution_mode:
		0:
			DisplayServer.window_set_size(resolutions[0]);
		1:
			DisplayServer.window_set_size(resolutions[1]);
		2:
			DisplayServer.window_set_size(resolutions[2]);
		_:
			DisplayServer.window_set_size(resolutions[0]);
	
	match fullscreen_mode:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, !DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS));
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN);
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

	match story_mode:
		0:
			story = "AA1";
		1:
			story = "AA2";
		_:
			story = "MOD";
	
	match fps_mode:
		30: Engine.max_fps = fps_options[0];
		120: Engine.max_fps = fps_options[2];
		140: Engine.max_fps = fps_options[140];
		144: Engine.max_fps = fps_options[144];
		_: Engine.max_fps = fps_options[1];

	# 0 DB Volume = Full volume. Higher than that will kill your ears. (100db, ouch).
	if volume > 100:
		volume = 100;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume - 100);
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), musicVolume - 100);
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfxVolume - 100);
	pass

func _ready():
	var loadahh = _load_settings(); # Inline function.
	if loadahh != OK:
		match load:
			_:
				LevelManager.error(load, "Error");
	if first_run:
		_save_settings();
