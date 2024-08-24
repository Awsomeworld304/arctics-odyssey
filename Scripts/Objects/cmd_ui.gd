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

@onready var input = $main/main/input;
@onready var help = $main/main/help;
@onready var anim = $anim;

var onScreen = false;
var cmd:="";

func _ready() -> void:
	input.focus_mode = Control.FocusMode.FOCUS_ALL;

func slide_in():
	anim.play("slide_in");
	await anim.animation_finished;
	onScreen = true;
	input.grab_focus();

func slide_out():
	input.clear();
	input.release_focus();
	anim.play("slide_out");
	await anim.animation_finished;
	onScreen = false;

func _on_input_text_submitted(new_text: String) -> void:
	cmd = new_text;
	await CommandManager.parse_cmd(cmd);
	if CommandManager.error != "OK":
		return;
	slide_out();
	pass
