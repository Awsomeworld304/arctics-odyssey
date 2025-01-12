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
var command:String = "";
var error:String = "OK";
var msg:String = "";

signal parsed_command

## The script base extends the CommandScript class and overrides [member custom].
var script_base:String = "extends CommandScript; func custom() -> void:";

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		if !CommandPrompt.onScreen: CommandPrompt.slide_in();
		else: CommandPrompt.slide_out();

func parse_cmd(cmd:String="") -> void:
	if cmd == "":
		error = "No Command Provided!";
		parsed_command.emit();
		return;
	
	if cmd == "help":
		error = "SHOW_HELP";
		msg = "Showing help page...";
		parsed_command.emit();
		return;
	
	var script:GDScript = GDScript.new();
	script.source_code = script_base as String + "	" + cmd as String;
	if Settings.debug: print("CommandManager -> Command: " + cmd);
	if script.reload() == OK:
		var obj:Object = script.new();
		if obj.has_method("custom") && obj != null:
			(obj as CommandScript).custom();
			error = "OK";
		else:
			error = "Error";
			msg = "Script object does not have the method named \'custom\'.";
	else: error = var_to_str(script.reload());
	parsed_command.emit();
