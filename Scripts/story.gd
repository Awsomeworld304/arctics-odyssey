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

# Scene References
@onready var error_text = $fallback_bg/fallback_text;
@onready var loading_text = $fallback_bg/loading_text;
@onready var main = $main;
@onready var hud = $hud;
@onready var parallax_bg = $fallback_bg/parallax_bg;

# This holds the 
var max_seg : int = 0;
var segment_counter : int = max_seg;

func _init() -> void:
	pass

func _ready() -> void:
	#fallback(true);
	pass
	
func _process(_delta: float) -> void:
	pass

func fallback(isError : bool = true) -> void:
	parallax_bg.visible = true;
	main.visible = false;
	hud.visible = false;
	if isError:
		loading_text.visible = false;
		error_text.visible = true;
	else:
		loading_text.visible = true;
	pass

func load():
	#$main/bg.texture = load();
	pass
