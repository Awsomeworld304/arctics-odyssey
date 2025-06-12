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

extends Node

# General
var inBattle = false;

var entities = [
	"player",
	"enemy"
];

# Player
var PlayerHealth:int = 100;
var PlayerMaxHealth:int = 100;
var PlayerMana:int = 50;
var PlayerMaxMana:int = 50;

# Enemy
var EnemyHealth:int = 100;
var EnemyMaxHealth:int = 100;
var EnemyMana:int = 50;
var EnemyMaxMana:int = 50;
var isBoss:bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func attack() -> void:
	pass

func block() -> void:
	pass

func add_mana(_amount:int, _entity:String = "player") -> void:
	pass
	
func add_health(_amount:int) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
