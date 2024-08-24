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

@onready var load_window = $editor/load_dialog;
@onready var save_window = $editor/save_dialog;

@onready var editor = $editor/edit/editor;

func _ready() -> void:
	pass

func _on_load_script_button_up() -> void:
	load_window.visible = true;
	pass # Replace with function body.


func _on_save_script_button_up() -> void:
	save_window.visible = true;
	pass # Replace with function body.


func _on_load_dialog_file_selected(path: String) -> void:
	var lol := FileAccess.open(path, FileAccess.READ);
	editor.text = lol.get_as_text();
	lol.close();
	pass # Replace with function body.


func _on_save_dialog_file_selected(path: String) -> void:
	var lol := FileAccess.open(path, FileAccess.WRITE);
	lol.store_string(editor.text);
	lol.close();
	pass # Replace with function body.
