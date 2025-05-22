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
const save_file:String = "user://AO/EngineSettings.sav";
const mod_file:String = "user://AO/ModSettings.sav";
const save_dir:String = "user://AO/";

## File Version - Used in case of the settings updating.
const secret:int = 1;

var debug:bool = true;

## A flag that triggers a function to save in some conditions.[br]
## Do NOT manually set this flag! You will absolutely throw the engine off and permanently destroy the engine save files!
var _save_flag:bool = false;

# Error Stuff
var errorCode:int = 0;
var errormsg:String = "";

# Graphics
# windowed, borderless windowed, fullscreen, ex. fullscreen.
var fullscreen_mode:int = 0;
var resolutions:Array[Vector2i]  = [Vector2i(640, 360), Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1080)];
var resolution_mode:int = 2;
var max_framerate:int = 144;

# Gameplay
var story_mode:int = 0;
var story:String = "NONE";

# Audio
var volume:float = 100.0; # Master
var musicVolume:float = 100.0;
var sfxVolume:float = 100.0;

## Saves engine variables and settings to save file.[br]
## The file can be located at ```user://AO/EngineSettings.sav```.
func _save_settings() -> Error:
	# Setup Save
	var save_items:Dictionary = {
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
		if DirAccess.make_dir_absolute(save_dir) != OK: return DirAccess.get_open_error();
	var save_write:FileAccess = FileAccess.open(save_file, FileAccess.WRITE);
	var json_string:String = JSON.stringify(save_items);
	save_write.store_line(json_string);
	save_write.close();
	if save_write.get_error() != OK && save_write.get_error() != null: return save_write.get_error();
	elif save_write.get_error() == null: return FileAccess.get_open_error();
	return OK;

## Loads the engine/settings save file.
func _load_settings() -> Error:
	# Load Data from File
	if not FileAccess.file_exists(save_file):
		_save_flag = true;
		if debug:
			push_warning("Settings -> Load Settings: No save to load!");
			print_debug("Settings -> Load Settings: Loading default values!");
	var save_read:FileAccess = FileAccess.open(save_file, FileAccess.READ);
	if save_read != null:
		while save_read.get_position() < save_read.get_length():
			var json_pstring:String = save_read.get_line();

			# Creates the helper class to interact with JSON
			var json:JSON = JSON.new();

			# Check if there is any error while parsing the JSON string, skip in case of failure
			var parse_result:Error = json.parse(json_pstring);
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_pstring, " at line ", json.get_error_line());
				#LevelManager.errCode = parse_result 
				return parse_result;
			
			var parsed_data:Dictionary = json.get_data();
			
			# Check if save is the correct version.
			if parsed_data["key"] != secret:
				# Save file needs to update.
				if parsed_data["key"] == 0:
					print("Settings -> Converting old save to new version.");
					fullscreen_mode = parsed_data["fullscreen_mode"];
					resolution_mode = parsed_data["resolution_mode"];
					volume = parsed_data["volume"];
					musicVolume = parsed_data["music_volume"];
					sfxVolume = parsed_data["sfx_volume"];
					story_mode = parsed_data["story"];
					max_framerate = parsed_data["fps_mode"];
					_save_flag = true;
				else:
					LevelManager.error("Invalid Save File!");
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
					print(fullscreen_mode, resolution_mode, volume, story_mode, max_framerate, _save_flag);
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

## Loads mod settings into global access.[br]
## Not complete yet!
func _load_mod_settings() -> Error:
	return OK;

func init_discord() -> void:
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
func update_discord(details:String="^", state:String="^", l_img:String="^", l_img_txt:String="^", s_img:String="^", s_img_txt:String="^") -> void:
	
	DiscordRPC.details = details if !details.contains("^") else DiscordRPC.details;
	DiscordRPC.state = state if !state.contains("^") else DiscordRPC.state;
	DiscordRPC.large_image = l_img if !l_img.contains("^") else DiscordRPC.large_image;
	DiscordRPC.large_image_text = l_img if !l_img_txt.contains("^") else DiscordRPC.large_image_text;
	DiscordRPC.small_image = s_img if !s_img.contains("^") else DiscordRPC.small_image;
	DiscordRPC.small_image_text = s_img_txt if !s_img_txt.contains("^") else DiscordRPC.small_image_text;
	pass

func change(key:String, value:String="", value2:String="", save_settings:bool=false) -> void:
	match key:
		"max_framerate", "fps":
			if value.is_empty() or int(value) <= 0: 
				max_framerate = 60;
				Engine.max_fps = max_framerate;
				printerr("Settings (change) -> Invalid Framerate! Using default. (60)");
				print("Settings -> New FPS: " + var_to_str(max_framerate));
			else:
				max_framerate = int(value);
				Engine.max_fps = max_framerate;
				print("Settings (change) -> New FPS: " + var_to_str(max_framerate));
			pass
		"resolution", "res":
			if value2 != null:
				var new_res:Vector2i = Vector2i(int(value), int(value2));
				DisplayServer.window_set_size(new_res);
			elif value != null:
				DisplayServer.window_set_size(resolutions[int(value)]);
			else:
				printerr("Settings (change) -> Invalid resolution!");
		_:
			printerr("Settings (change) -> Invalid setting key!");
	if save_settings && _save_settings() != OK: LevelManager.error("Save error during settings save!");
	pass

func _ready() -> void:
	ErrorScene.hide();
	#_load_settings()
	if  OK != OK:
		print("Settings Error!");
		LevelManager.error();
	if _save_flag:
		pass##if _save_settings() != OK: LevelManager.error("Save error during settings save!");
	init_discord();

func _process(_delta: float) -> void:
	pass
