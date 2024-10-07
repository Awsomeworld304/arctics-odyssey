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

extends "res://Scripts/story.gd"

var file_name:String = "untitled";
var file_status:String = " (Unsaved)"
var file_name_buffer:String = "Current File: " + file_name + file_status;
var wait:bool = false;
var exit:bool = false;
var buffer:String = "";

var cur_step:int = 1;
var max_step:int = 0;

var code_checked:bool = false;
var always_check:bool = false;
var code:GDScript = GDScript.new();
var code_obj:StoryScript;

@onready var load_window:FileDialog = $editor/load_dialog as FileDialog;
@onready var save_window:FileDialog = $editor/save_dialog as FileDialog;

@onready var editor:CodeEdit = $editor/edit/editor as CodeEdit;
@onready var file_title:Label = $editor/edit/file as Label;

@onready var code_status:RichTextLabel = $editor/stats/code_stat as RichTextLabel;
@onready var cur_step_stat:RichTextLabel = $editor/stats/cur_step as RichTextLabel;

@onready var preview_dialog:RichTextLabel = $editor/preview/SubViewportContainer/SubViewport/hud/dialog/dialog as RichTextLabel;

func _ready() -> void:
	test_code(editor.text);
	check_steps(false);
	pass

func _process(_delta: float) -> void:
	if cur_step != preview_dialog.count+1:
		cur_step = preview_dialog.count+1;
		check_steps();
	if file_title.text != file_name_buffer:
		file_title.text = file_name_buffer;

func _on_load_script_button_up() -> void:
	load_window.visible = true;
	pass # Replace with function body.


func _on_save_script_button_up() -> void:
	save_window.visible = true;
	pass # Replace with function body.


func _on_load_dialog_file_selected(path: String) -> void:
	wait = true;
	var fn:String = path.split("/")[path.split("/").size()-1];
	file_name = fn;
	print("fn " + file_name);
	file_status = "";
	file_name_buffer = "Current File: " + file_name + file_status;
	var lol:FileAccess = FileAccess.open(path, FileAccess.READ);
	editor.text = lol.get_as_text();
	buffer = lol.get_as_text();
	lol.close();
	test_code(editor.text);
	pass # Replace with function body.


func _on_save_dialog_file_selected(path: String) -> void:
	buffer = editor.text;
	var lol:FileAccess = FileAccess.open(path, FileAccess.WRITE);
	lol.store_string(editor.text);
	lol.close();
	file_status = "";
	if exit:
		LevelManager.trans("Main");
	pass # Replace with function body.


func _on_editor_text_changed() -> void:
	code_checked = false;
	if !code_checked:
		code_status.text = "[color=gray]Unknown";
	if buffer != editor.text:
		file_status = " (Unsaved)";
		file_name_buffer = "Current File: " + file_name + file_status;
		if always_check:
			test_code(editor.text);
	else:
		file_status = "";
		file_name_buffer = "Current File: " + file_name + file_status;
	pass # Replace with function body.


func _on_exit_button_up() -> void:
	exit = true;
	if (file_status != ""):
		save_window.visible = true;
	else:
		LevelManager.trans("Main");
	pass # Replace with function body.


func _on_save_dialog_canceled() -> void:
	if exit:
		LevelManager.trans("Main");
	pass # Replace with function body.

## Returns true if code is valid.
func test_code(code:String) -> bool:
	StoryManager.story_list.clear();
	StoryManager.cntr = 0;
	self.code.source_code = code;
	if code == "":
		code_status.text = "[color=gray]Unknown";
		return false;
	var tt:Error = self.code.reload();
	if tt == OK:
		code_obj = self.code.new();
		code_obj.script();
		preview_dialog.setup();
		code_checked = true;
		code_status.text = "[color=green][wave freq=5f]Valid code![/wave]";
		return true;
	else:
		code_checked = true;
		code_status.text = "[color=red][wave freq=5f]Invalid code.[/wave]";
	return false;


func _on_reload_code_button_up() -> void:
	test_code(editor.text);
	check_steps(false);
	StoryManager.load_chapter();
	load_new_scene();
	await StoryManager.chapter_loaded;
	pass # Replace with function body.

func _on_editor_opt_button_up() -> void:
	$editor/editor_options.visible = !$editor/editor_options.visible;
	pass # Replace with function body.


func _on_auto_parse_toggled(toggled_on: bool) -> void:
	always_check = toggled_on;
	pass # Replace with function body.

func check_steps(skip_setup:bool = true) -> void:
	if StoryManager.cntr > 0 && !skip_setup:
		print("story list story: " + var_to_str(StoryManager.text.size()));
		max_step = StoryManager.text.size();
	var ptl:String = "";
	var ptr:String = "";
	match cur_step:
		0: ptl = "[color=gray]";
		max_step: ptl = "[color=red]";
		_: ptl = "[color=blue]";
	cur_step_stat.text = ptl +  var_to_str(cur_step) + "[color=white] of " + ptr + var_to_str(max_step);

func load_new_scene() -> void:
	preview_dialog.setup();
	pass
