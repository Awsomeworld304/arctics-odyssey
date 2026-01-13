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

signal miss_note(note:Note);

## The name of the note: ["left", "down", "center", "up", "right"].
@export var key_name:StringName = "";
## Note type, currently only normal exists.
@export var type:StringName = "normal";
## Note position in the song ms.
@export var time:float = 0.0;
@export var hold_time:float = 0.0;
## Events do not matter yet.
#@export var events:Array[StringName] = [];

## The exact time in MS that the note was hit.
var hit_time:float = -32;
var frames:SpriteFrames = preload("res://Assets/sprite/note.tres");
var _missed:bool = false;
var hold_segments:Array[Sprite2D] = [];

func _ready() -> void:
	sprite_frames = frames;
	animation = key_name;
	pass

func set_note_skin(skin:String) -> void:
	frames = load("res://Assets/sprite/%s.tres" % skin);
	sprite_frames = frames;
	animation = key_name;
	pass

func add_hold() -> void:
	if hold_time <= 0: return;
	
	var hold_px:int = floori(hold_time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed));
	
	for i:int in range(hold_px - (32/2) - 1):
		var seg:Sprite2D = Sprite2D.new();
		seg.texture = frames.get_frame_texture("hold", 0);
		seg.position.y = (32/2) + i;
		seg.name = "hold_" + str(i);
		seg.show_behind_parent = true;
		
		hold_segments.append(seg);
		pass
	
	var fseg:Sprite2D = Sprite2D.new();
	fseg.texture = frames.get_frame_texture("hold_end", 0);
	fseg.position.y = ((32/2) + (hold_segments.size() -1));
	fseg.name = "hold_" + str((hold_segments.size() -1));
	fseg.show_behind_parent = true;
	hold_segments.append(fseg);
	
	for seg:Sprite2D in hold_segments:
		add_child(seg);
	pass

func update_hold() -> void:
	for seg:Sprite2D in hold_segments:
		if (is_held() and self.position.y > 0):
			self.self_modulate = Color.TRANSPARENT;
			pass
		else: self.self_modulate = Color.WHITE;
		if (self.position.y + hold_segments.find(seg)) < (0 if is_held() else -32):
			seg.visible = false;
			pass
		else: seg.visible = true;
			
		pass
	pass

func is_held() -> bool:
	return Input.is_action_pressed(key_name);

func hold_finished() -> bool:
	return (self.position.y + hold_segments.find((hold_segments.size()-1)) >= 0);

func _process(_delta: float) -> void:
	self.position.y = (self.time - Conductor.position) * (Conductor.bpm / 60.0) * Conductor._offset_scroll_modifier * Conductor.scroll_speed;
	
	
	# Really hacky, find a better way.
	if (self.hold_time > 0):
		update_hold();
		
		if (self.position.y + hold_segments.size()) <= -32:
			self.visible = false;
			if !_missed:
				miss_note.emit(self);
				_missed = true;
				pass
		elif hit_time == -32: self.visible = true;
		pass
	else:
		if self.position.y <= -32:
			self.visible = false;
			if !_missed:
				miss_note.emit(self);
				_missed = true;
				pass
		elif hit_time == -32: self.visible = true;
		pass
	pass
