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
class_name Strumline

@onready var left:AnimatedSprite2D = $left as AnimatedSprite2D;
@onready var down:AnimatedSprite2D = $down as AnimatedSprite2D;
@onready var center:AnimatedSprite2D = $center as AnimatedSprite2D;
@onready var up:AnimatedSprite2D = $up as AnimatedSprite2D;
@onready var right:AnimatedSprite2D = $right as AnimatedSprite2D;

func add_note(note:Note) -> void:
	pass

func add_chart() -> void:
	pass
