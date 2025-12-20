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

extends Node2D

@onready var devmenu:CanvasLayer = $DevMenu as CanvasLayer;
@onready var anim:AnimationPlayer = $anim as AnimationPlayer;
@onready var update_label:RichTextLabel = $menu/main/version as RichTextLabel;
@onready var song_list:ItemList = $freeplay/main/song_list as ItemList;

var songs:Dictionary[String, String];

func _ready() -> void:
	update_label.text = "[center][rainbow freq=0.2][wave amp=50.0 freq=10.0 connected=1] V: %s\n[center][font_size=16]Pre-Alpha" % Settings.GAME_VERSION;
	
	songs = ModLoader.find_songs();
	
	for song_name:String in songs.keys():
		var _idx:int = song_list.add_item(song_name);
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug2"):
		devmenu.visible = !devmenu.visible;
		pass
	pass

func _on_dev_menu_visibility_changed() -> void:
	pass

#region Main Menu
func _on_start_button_up() -> void:
	#LevelManager.load_scene("test_stage", false, true);
	($freeplay as CanvasLayer).visible = true;
	pass

func _on_opt_button_up() -> void:
	LevelManager.load_scene("options");
	pass

func _on_quit_button_up() -> void:
	anim.play("fade_out");
	await anim.animation_finished;
	LevelManager.quit();
	pass # Replace with function body.
#endregion

#region Freeplay
func _on_song_list_item_selected(index: int) -> void:
	if songs.keys().get(index) != null and songs.get(songs.keys()[index]) != null:
		print("Valid song chosen at: %s" % songs.keys()[index]);
		pass
	pass
#endregion
