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

extends Node2D

@export var error:String = "Unknown Fatal Error!";

@onready var text:RichTextLabel = ($fallback_bg/fallback_text as RichTextLabel);

var error_start:String = "[wave freq=5 amp=25][center]Whoops!\nYou're [i]not[/i] supposed to see [color=red]this![color=purple][bgcolor=black]\n";
var error_end:String = "[/bgcolor][p]\n[center][color=white]Please contact the devs and report this bug, thanks in advance!";

func _ready() -> void:
	self.visible = false;
	($fallback_bg as CanvasLayer).visible = false;
	($fallback_bg/bg as CanvasLayer).visible = false;
	pass

func change_error(msg:String="Unknown Fatal Error!") -> void:
	error = msg;
	text.text = error_start + error + error_end;
	self.visible = true;
	($fallback_bg as CanvasLayer).visible = true;
	($fallback_bg/bg as CanvasLayer).visible = true;


func _on_exit_button_up() -> void:
	LevelManager.trans("Main");
	self.visible = false;
	($fallback_bg as CanvasLayer).visible = false;
	($fallback_bg/bg as CanvasLayer).visible = false;
	pass # Replace with function body.
