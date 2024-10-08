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
var save_file = "user://AO/EngineSettings.sav";
var mod_file = "user://AO/ModSettings.sav";
var save_dir = "user://AO/";

## File Version - Used in case of the settings updating.
var secret = 1;

var debug = true;

## Saves the file after loading defaults.
var first_run = false;

# Error Stuff
var errorCode = 0;
var errormsg = "";

# Graphics
# windowed, borderless windowed, fullscreen, ex. fullscreen.
var fullscreen_mode = 2;
var resolutions  = [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1920, 1080), Vector2i(2560, 1080)];
var resolution_mode = 2;
var max_framerate := 60;

# Gameplay
# 0 - 5 | Story mode.
var story_mode = 0;
var story = "MOD";

# Audio
var volume = 100.0; # Master
var musicVolume = 100.0;
var sfxVolume = 100.0;

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
		"max_framerate" : max_framerate,
		"debug" : debug
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
		first_run = true;
		if debug:
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
			
			# Check if save is the correct version.
			if parsed_data["key"] != secret:
				# Save file needs to update.
				if parsed_data["key"] == 0:
					print("Settings -> Converting old save to new version.");
					parsed_data["fullscreen_mode"] = fullscreen_mode;
					parsed_data["resolution_mode"] = resolution_mode;
					parsed_data["volume"] = volume;
					parsed_data["music_volume"] = musicVolume;
					parsed_data["sfx_volume"] = sfxVolume;
					parsed_data["story"] = story_mode;
					var fpsm = parsed_data["fps_mode"];
					max_framerate = fpsm;
					first_run = true;
				else:
					LevelManager.error();
			else:
				fullscreen_mode = parsed_data["fullscreen_mode"];
				resolution_mode = parsed_data["resolution_mode"];
				volume = parsed_data["master_volume"];
				musicVolume = parsed_data["music_volume"];
				sfxVolume = parsed_data["sfx_volume"];
				story_mode = parsed_data["story"];
				max_framerate = parsed_data["max_framerate"];
				debug = parsed_data["debug"];
				if debug:
					print(fullscreen_mode, resolution_mode, volume, story_mode, max_framerate, first_run);
	# Set settings.
	match resolution_mode:
		0: DisplayServer.window_set_size(resolutions[0]);
		1: DisplayServer.window_set_size(resolutions[1]);
		2: DisplayServer.window_set_size(resolutions[2]);
		3: DisplayServer.window_set_size(resolutions[3]);
		_: DisplayServer.window_set_size(resolutions[0]);
	
	match fullscreen_mode:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, !DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS));
		2: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN);
		_: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

	match story_mode:
		0: story = "Campaign";
		_: story = "null";
	
	Engine.max_fps = max_framerate;
	
	# 0 DB Volume = Full volume. Higher than that will kill your ears. (100db, ouch).
	if volume > 100:
		volume = 100;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume - 100);
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), musicVolume - 100);
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfxVolume - 100);
	return OK;

func init_discord():
	DiscordRPC.app_id = 1276697909823279196;
	DiscordRPC.details = "In current developement." if debug else "In the Menus";
	DiscordRPC.state = ""
	DiscordRPC.large_image = "logo"
	#DiscordRPC.large_image_text = ""
	#DiscordRPC.small_image = ""
	#DiscordRPC.small_image_text = "";
	pass

## Update the Discord RPC.[br]
## The defaut character [^] is used to indicate to keep using the previous config.
func update_discord(details:="^", state:="^", l_img:="^", l_img_txt:="^", s_img:="^", s_img_txt:="^"):
	
	DiscordRPC.details = details if !details.contains("^") else DiscordRPC.details;
	DiscordRPC.state = state if !state.contains("^") else DiscordRPC.state;
	DiscordRPC.large_image = l_img if !l_img.contains("^") else DiscordRPC.large_image;
	DiscordRPC.large_image_text = l_img if !l_img_txt.contains("^") else DiscordRPC.large_image_text;
	DiscordRPC.small_image = s_img if !s_img.contains("^") else DiscordRPC.small_image;
	DiscordRPC.small_image_text = s_img_txt if !s_img_txt.contains("^") else DiscordRPC.small_image_text;
	pass

func change(key:String, value=null, value2=null):
	match key:
		"max_framerate":
			if value == null or value <= 0: 
				max_framerate = 60;
				Engine.max_fps = max_framerate;
				printerr("Settings (change) -> Invalid Framerate! Using default. (60)");
				print("Settings -> New FPS: " + var_to_str(max_framerate));
			else:
				max_framerate = value;
				Engine.max_fps = max_framerate;
				print("Settings (change) -> New FPS: " + var_to_str(max_framerate));
			pass
		"res":
			if value2 != null:
				var new_res = Vector2i(value, value2);
				DisplayServer.window_set_size(new_res);
			elif value != null:
				DisplayServer.window_set_size(resolutions[value]);
			else:
				printerr("Settings (change) -> Invalid resolution!");
		_:
			printerr("Settings (change) -> Invalid setting key!");
	pass

func _ready():
	ErrorScene.hide();
	if  _load_settings() != OK:
		print("Settings Error!");
		LevelManager.error();
	if first_run:
		_save_settings();
	init_discord();

func _process(_delta: float) -> void:
	pass
