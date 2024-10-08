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

# God help my soul for what I have to do here.
var command := "";
var error := "OK";

signal parsed_command

var script_base := """
extends Node

func custom() -> void:
"""

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		if !CommandPrompt.onScreen:
			CommandPrompt.slide_in();
		else:
			CommandPrompt.slide_out();

func parse_cmd(cmd:=""):
	if cmd == "":
		error = "No Command Provided!";
		parsed_command.emit();
		return;
	
	if cmd == "help":
		error = "SHOW_HELP";
		parsed_command.emit();
		return;
	
	var script = GDScript.new();
	script.source_code = script_base + "	" + cmd;
	if Settings.debug: print("CommandManager -> Command: " + cmd);
	if script.reload() == OK:
		var obj = script.new();
		obj.custom();
		error = "OK";
	parsed_command.emit();
