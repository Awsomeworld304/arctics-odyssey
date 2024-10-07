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

@onready var trans_anim:AnimationPlayer = $"../TransitionLayer".get_node("anim") as AnimationPlayer;

signal level_changed;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass

# Handle it ourselves because 4.2+ makes scene changes instant which causes flickering.
func change_level(level : String, object:bool = false, global:bool = false) -> void:
	var levelPath:String = "";
	if object:
		levelPath = "res://Scenes/Objects/" + level + ".tscn";
	elif  global:
		levelPath = "res://Globals/" + level + ".tscn";
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
			if Settings.debug:
				print_debug("Loading " + level + "...");
	# Wait for very last frame, to switch it on a good frame!
	await get_tree().process_frame;
	# Changes the scene to the specified level.
	get_tree().change_scene_to_file(levelPath);
	#await get_tree().current_scene.ready;
	level_changed.emit();
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

func quit(code:=0):
	get_tree().quit(code);

func trans(level:String, global:=false, _trans:="default"):
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

func error(msg:="Unknown Fatal Error!"):
	LevelManager.trans("ErrorScene", true);
	ErrorScene.change_error(msg);
	pass
