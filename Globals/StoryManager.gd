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

# File Stuff
var static_path = "res://Assets/Dialog/";
var curText = "";
var chapter = "test";
var dialog_file = "test";
var save_dir = static_path + chapter;
var save_path = save_dir + "/" + dialog_file + ".script";
var test_path = "user://test.script"

## Text Buffer - holds current segment text in buffer for use.
var text = {
	0: "Yeah I'm [rainbow freq=0.1][wave]gay.[/wave][/rainbow]",
	1: "So, you got a problem with that pal?",
	2: "[color=red][wave]Fight me about it then!"
}

# Event Trigger
# Method 1: Loading files into the scene.
# Action | Type | Name | Resource

# Method 2: Command | Command Name | 
var events = {
	0: "create|image|bg0|res://Assets/Images/BG/test.png",
	1: "",
	2: ""
}

func _ready() -> void:
	# Did this to prevent the game locking during save and causing havoc to my stack.
	process_mode = Node.PROCESS_MODE_ALWAYS;
	pass

## Starts by reading the very first story file it can find.
func start():
	pass

func _process(_delta: float) -> void:
	pass

func load_dialog(file_name := "test", _chapter := "test"):
	var fpath = static_path + _chapter + "/";
	var _dialog_thing = ScriptManager.load_script(file_name + ".script", fpath);
	if _dialog_thing == null:
		printerr("StoryManager -> Error loading dialog script!");
		return;
	pass

func save_dialog(script:Dictionary, _chapter := "test"):
	var fpath = static_path + _chapter + "/";
	var ss := ScriptManager.save_script(script, fpath);
	if ss != OK:
		printerr("StoryManager -> Error saving dialog script, error code: " + var_to_str(ss));
		return;
	pass
