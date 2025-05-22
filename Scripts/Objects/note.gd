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

class_name Note
extends AnimatedSprite2D

@export var key_name:StringName;
@export var data:NoteData = NoteData.new();
## The exact time in MS that the note was hit.
var hit_time:float = 0;
var frames:SpriteFrames = preload("res://Assets/sprite/note.tres");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data.key_name = key_name;
	sprite_frames = frames;
	animation = key_name;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Conductor.is_playing: self.position.y -= Conductor.scroll_speed * (Conductor.bpm / 60.0) * delta;
	pass
