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

var current_scene:String = "";
var previous_scene:String = "";

@onready var trans_anim:AnimationPlayer = $"../TransitionLayer".get_node("anim") as AnimationPlayer;

signal level_changed;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cycle_scenes();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	pass

func cycle_scenes() -> void:
	# Set previous scene.
	previous_scene = current_scene;
	# Get new current scene.
	if (get_tree().current_scene != null): current_scene = get_tree().current_scene.name;
	print("LevelManager -> Current Scene: " + current_scene);
	pass

## Custom scene changer.[br]
## Paramaters:[br]
## level (String) - The file name of the level.[br]
## object (Bool) - Specifies if the loaded scene is an object.[br]
## global (Bool) - Specifies if the loaded scene is a global scene.
func change_level(level : String, object:bool = false, global:bool = false) -> void:
	var levelPath:String = "";
	if object: levelPath = "res://Scenes/Objects/" + level + ".tscn";
	elif global: levelPath = "res://Globals/" + level + ".tscn";
	else: levelPath = "res://Scenes/" + level + ".tscn";
	
	match level:
		"": printerr("LevelManager: Invalid args for level!"); return;
		_:
			if !FileAccess.file_exists(levelPath): printerr("LevelManager: Level not found!"); return;
			if Settings.debug: print_debug("Loading " + level + "...");
	# Wait for last frame. (4.2+ | Fixes transitions.)
	await get_tree().process_frame;
	var _err:Error = get_tree().change_scene_to_file(levelPath);
	await get_tree().tree_changed;
	cycle_scenes();
	level_changed.emit();
	pass

## Restarts current scene.
func reload(restart_to_main:bool = false) -> void:
	if get_tree().paused == true: get_tree().paused = false;
	await get_tree().process_frame;
	if restart_to_main:
		var _err:Error = get_tree().change_scene_to_file("res://Scenes/Main.tscn");
		_err = Settings._load_settings();
	else: var _err:Error = get_tree().reload_current_scene();

func quit(code:int = 0) -> void:
	get_tree().quit(code);

func trans(level:String, global:bool = false, _trans:String = "default") -> void:
	match _trans:
		_:
			trans_anim.play("default");
			await trans_anim.animation_finished;
			change_level(level, false, global);
			await level_changed;
			trans_anim.play_backwards("default");
			await trans_anim.animation_finished;
			pass
	pass

func error(msg:String = "Unknown Fatal Error!") -> void:
	LevelManager.trans("ErrorScene", true);
	ErrorScene.change_error(msg);
	pass
