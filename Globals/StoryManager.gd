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
const static_path:String = "res://Assets/Dialog/";
var curText:String = "";
var chapter:String = "test";
var dialog_file:String = "test";
var save_dir:String = static_path + chapter;
var save_path:String = save_dir + "/" + dialog_file + ".script";
var test_path:String = "user://test.script";

signal chapter_loaded;

## Text Buffer - holds current segment text in buffer for use.
var text:Dictionary = {
	0: "Yeah I'm [rainbow freq=0.1][wave]gay.[/wave][/rainbow]",
	1: "So, you got a problem with that pal?",
	2: "[color=red][wave]Fight me about it then!"
};

## Event Trigger
## Runs a function from your StoryScript instance.
var events:Dictionary = {
	0: ""
}

var story_list:Dictionary = {};

func _ready() -> void:
	# Did this to prevent the game locking during save and causing havoc.
	process_mode = Node.PROCESS_MODE_ALWAYS;
	pass

## Starts by reading the very first story file it can find.
func start() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func load_dialog(file_name:String = "test", _chapter:String = "test") -> void:
	var fpath:String = static_path + _chapter + "/";
	var _dialog_thing:Dictionary = ScriptManager.load_script(file_name + ".script", fpath);
	if _dialog_thing == null:
		printerr("StoryManager -> Error loading dialog script!");
		return;
	pass

func save_dialog(script:Dictionary, _chapter:String = "test") -> void:
	var fpath:String = static_path + _chapter + "/";
	var ss:Error = ScriptManager.save_script(script, fpath);
	if ss != OK:
		printerr("StoryManager -> Error saving dialog script, error code: " + var_to_str(ss));
		return;
	pass

var cntr:int=0;
func _reg_script(script:StoryScript) -> void:
	story_list.get_or_add(cntr, script);
	cntr+=1;
	print(story_list);
	pass

func load_chapter() -> void:
	var assfuck:StoryScript = story_list.get(cntr-1 if (cntr > 0) else cntr);
	print(assfuck.dialog_lines);
	text = assfuck.dialog_lines;
	events = assfuck.event_lines;
	chapter_loaded.emit();
	pass
