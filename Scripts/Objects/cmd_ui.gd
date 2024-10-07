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

extends Control

@onready var input:LineEdit = $main/main/input as LineEdit;
@onready var help:RichTextLabel = $main/main/help as RichTextLabel;
@onready var anim:AnimationPlayer = $anim as AnimationPlayer;
@onready var hanim:AnimationPlayer = $helpanim as AnimationPlayer;

var onScreen:bool = false;
var cmd:String = "";

var helpVisible:bool = false;

func _ready() -> void:
	input.focus_mode = Control.FocusMode.FOCUS_ALL;

func slide_in() -> void:
	anim.play("slide_in");
	await anim.animation_finished;
	onScreen = true;
	input.grab_focus();

func slide_out() -> void:
	input.clear();
	input.release_focus();
	if helpVisible == true: toggle_help();
	anim.play("slide_out");
	await anim.animation_finished;
	onScreen = false;

func toggle_help() -> void:
	input.clear();
	if helpVisible: hanim.play_backwards("help_show");
	else: hanim.play("help_show");
	await hanim.animation_finished;
	helpVisible = !helpVisible;
	pass

func _on_input_text_submitted(new_text: String) -> void:
	cmd = new_text;
	CommandManager.parse_cmd(cmd);
	await CommandManager.parsed_command;
	if CommandManager.error == "SHOW_HELP": print("Help has been ran!"); toggle_help(); return;
	if CommandManager.error != "OK":
		help.text = "[color=red][wave freq=5]Error: " + CommandManager.error;
		return;
	else: help.text = "";
	slide_out();
	pass
