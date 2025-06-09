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

@onready var editorcl:CanvasLayer = $"editor" as CanvasLayer;

func _enter_tree() -> void:
	get_window().content_scale_size = Vector2i(1920, 1080);
	FPS.fix_scale();
	pass

func _ready() -> void:
	#editorcl.
	pass

func _exit_tree() -> void:
	get_window().content_scale_size = Vector2i(640, 360);
	FPS.fix_scale();
	pass


func _on_exit_button_up() -> void:
	LevelManager.load_scene(LevelManager.previous_scene if (LevelManager.previous_scene != "" && LevelManager.previous_scene != "ScriptEditor") else "Error");
	pass # Replace with function body.
