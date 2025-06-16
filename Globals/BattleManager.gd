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
var in_battle = false;
var current_battle:BattleInstance;

func start_battle(player:Character, opponent:Character) -> BattleInstance:
	var new_battle:BattleInstance = BattleInstance.new();
	
	return new_battle;

func end_battle() -> void:
	pass
