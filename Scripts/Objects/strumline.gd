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

@onready var left := $left;
@onready var down := $down;
@onready var center := $center;
@onready var up := $up;
@onready var right := $right;

signal left_p
signal down_p
signal center_p
signal up_p
signal right_p 

signal left_r
signal down_r
signal center_r
signal up_r
signal right_r

func _ready() -> void:
	pass

func _process(_delta: float) -> void:	
	if Input.is_action_just_pressed("left"):
		left_p.emit();
		left.frame = 1;
	elif Input.is_action_just_released("left"):
		left_r.emit();
		left.frame = 0;
		pass
	
	if Input.is_action_just_pressed("down"):
		down_p.emit();
		down.frame = 1;
	elif Input.is_action_just_released("down"):
		down_r.emit();
		down.frame = 0;
		pass
	
	if Input.is_action_just_pressed("center"):
		center_p.emit();
		center.frame = 1;
	elif Input.is_action_just_released("center"):
		center_r.emit();
		center.frame = 0;
		pass
	
	if Input.is_action_just_pressed("up"):
		up_p.emit();
		up.frame = 1;
	elif Input.is_action_just_released("up"):
		up_r.emit();
		up.frame = 0;
		pass
	
	if Input.is_action_just_pressed("right"):
		right_p.emit();
		right.frame = 1;
	elif Input.is_action_just_released("right"):
		right_r.emit();
		right.frame = 0;
		pass
	pass
