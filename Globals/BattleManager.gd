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

extends Node

# General
var inBattle = false;

var entities = [
	"player",
	"enemy"
];

# Player
var PlayerHealth = 100;
var PlayerMaxHealth = 100;
var PlayerMana = 50;
var PlayerMaxMana = 50;

# Enemy
var EnemyHealth = 100;
var EnemyMaxHealth = 100;
var EnemyMana = 50;
var EnemyMaxMana = 50;
var isBoss = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func attack():
	pass

func block():
	pass

func add_mana(_amount:int, _entity:String = "player"):
	pass
	
func add_health(_amount:int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
