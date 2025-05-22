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

func _ready() -> void:
	pass

# TODO: Refactor!!
func play_audio(audioName:NodePath, startTime:float = 0.0,speed:float = 1) -> void:
	if get_node(audioName) != null:
		(get_node(audioName) as AudioStreamPlayer).pitch_scale = speed
		(get_node(audioName) as AudioStreamPlayer).play(startTime)
	pass

func stop_audio(audioName:NodePath) -> void:
	if get_node(audioName) != null:
		(get_node(audioName) as AudioStreamPlayer).stop()
		
func get_audio_playback(audioName:NodePath) -> float:
	if get_node(audioName) != null:
		return (get_node(audioName) as AudioStreamPlayer).get_playback_position() + AudioServer.get_time_since_last_mix();
	else: return 0.0;
