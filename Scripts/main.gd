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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug2"):
		$DevMenu.visible = !$DevMenu.visible;
	pass


func _on_start_button_up() -> void:
	LevelManager.trans("stage");
	pass # Replace with function body.


func _on_opt_button_up() -> void:
	LevelManager.trans("options");
	pass


func _on_quit_button_up() -> void:
	$anim.play("fade_out");
	await $anim.animation_finished;
	LevelManager.quit();
	pass # Replace with function body.

func _on_dev_menu_visibility_changed() -> void:
	pass # Replace with function body.
