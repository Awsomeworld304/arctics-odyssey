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



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Handle it ourselves because 4.2 makes scene changes instant which causes flickering.
func change_level(level : String, object = false):
	var levelPath = "";
	if object:
		levelPath = "res://Scenes/Objects/" + level + ".tscn";
	else:
		levelPath = "res://Scenes/" + level + ".tscn";
		
	match level:
		"":
			printerr("LevelManager: Invalid args for level!");
			return;
		_:
			if !FileAccess.file_exists(levelPath):
				printerr("LevelManager: Level not found!");
				return;
			print_debug("Loading " + level + "...");
	# Wait for very last frame, to switch it on a good frame!
	await get_tree().process_frame;
	# Changes the scene to the specified level.
	get_tree().change_scene_to_file(levelPath);
	pass
	
func reload(restart = false):
	if get_tree().paused == true:
		get_tree().paused = false;
	if restart:
		await get_tree().process_frame;
		get_tree().change_scene_to_file("res://Scenes/Main.tscn");
		Settings._load_settings();
	else:
		await get_tree().process_frame;
		get_tree().reload_current_scene();

func quit():
	get_tree().quit(0);
