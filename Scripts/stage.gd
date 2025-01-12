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

@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;

func _ready() -> void:
	Conductor.player = player;
	var _s:int = Conductor.quarter_will_pass.connect(_on_conductor_quarter_will_pass);
	Conductor.play();
	pass


func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug2"): Conductor.pause();
	pass


func _on_conductor_quarter_will_pass(beat: int) -> void:
	var text:String = "Cached Latency: " + var_to_str(Conductor._cached_latency) + "\n";
	text += "Beat: " + var_to_str((beat % 4) +1) + "\n";
	($"main/debuginfo" as RichTextLabel).text = text;
	pass