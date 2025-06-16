# Copyright (C) 2024 - 2025 JamesTech4849
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

class_name Note
extends AnimatedSprite2D

## The name of the note: ["left", "down", "center", "up", "right"].
@export var key_name:StringName = "";
## Note type, currently only normal exists.
@export var type:StringName = "normal";
## Note position in the song ms.
@export var time:float = 0.0;
## Events do not matter yet.
#@export var events:Array[StringName] = [];

## The exact time in MS that the note was hit.
var hit_time:float = -32;
var frames:SpriteFrames = preload("res://Assets/sprite/note.tres");

func _ready() -> void:
	sprite_frames = frames;
	animation = key_name;
	pass

func set_note(_name:String) -> void:
	#nframes:SpriteFrames = load(res://)
	pass

func _process(_delta: float) -> void:
	self.position.y = (self.time - Conductor.position) * (Conductor.bpm / 60.0) * Conductor._offset_scroll_modifier * Conductor.scroll_speed;
	
	# Really hacky, find a better way.
	if self.position.y <= -32: self.visible = false;
	elif hit_time == -32: self.visible = true;
	pass
