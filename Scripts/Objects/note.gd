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

extends AnimatedSprite2D

@onready var curName = self.animation.get_basename();
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.apply_scale(Vector2(0.1,0.1))
	self.position.y = 1000;
	match curName:
		"left":
			self.position.x = $"../left".position.x;
			pass;
		"up":
			self.position.x = $"../up".position.x;
			pass;
		"center":
			self.position.x = 0;
			pass
		"down":
			self.position.x = $"../down".position.x;
			pass;
		"right":
			self.position.x = $"../right".position.x;
			pass;
		_:
			self.position.x = 0;
			pass;
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y -= 1000*delta;
	pass
