extends Node


## The speed at which the text animation will play
@export var playback_speed = 1.5
## The speead at which each character will appear
@export var char_speed = 0.08
## The long stop delay
@export var long_stop_delay = 0.4
## The long stop characters
@export var long_stop_chars = [".", "?", "!"]
## The short stop delay
@export var short_stop_delay = 0.2
## The short stop characters
@export var short_stop_chars:Array = [",", ";", ":"];


@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	rich_text_label.bbcode_enabled = true
	rich_text_label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING

	#display("[b][wave]Hello![/wave][/b] How are you? I'm fine, I guess. I can play sounds!!! [rainbow]YAY![/rainbow]")
	#await animation_player.animation_finished
	#await get_tree().create_timer(2).timeout
	#display("Another sentence I can say, I'm not sure what else to say. What do you think?")

	
func display(text:String) -> void:
	# Stop the current animation
	animation_player.stop()

	# Reset the visible characters to 0 and set the text to be displayed
	rich_text_label.visible_characters = 0
	rich_text_label.text = text

	var animation = _generate_animation(rich_text_label.get_parsed_text())

	# If the animation player does not have a global animation library, create one
	if not animation_player.has_animation_library(""):
		animation_player.add_animation_library("", AnimationLibrary.new())
	var library = animation_player.get_animation_library("")

	# remove the old animation if it exists
	if library.has_animation("play_text"):
		library.remove_animation("play_text")

	# Add the new animation
	library.add_animation("play_text", animation)
	# Set the speed of the animation
	animation_player.speed_scale = playback_speed
	animation_player.play("play_text")


func play_sound(idx:int, char:String):
	audio_stream_player.play()


func _generate_animation(text:String) -> Animation:
	# Create a new animation with 2 tracks, one for the visible_characters and one for the play_sound()
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	var sound_index = animation.add_track(Animation.TYPE_METHOD)

	animation.track_set_path(track_index, "%s:visible_characters" % get_path_to(rich_text_label))
	animation.track_set_path(sound_index, get_path_to(self))

	# For each character check if it should skip the sound and add a delay
	# if the current character is inside one of the short/long characters array and if the next is a space
	var time = 0.0
	for i in text.length():
		var current_char = text[i]
		var next_char = null
		if i < text.length() - 1:
			next_char = text[i+1]

		var skip_sound = false
		if current_char == " ":
			skip_sound = true
		var delay = char_speed
		if next_char and next_char == " ":
			if current_char in short_stop_chars:
				delay = short_stop_delay
				skip_sound = true
			elif current_char in long_stop_chars:
				delay = long_stop_delay
				skip_sound = true

		animation.track_insert_key(track_index, time, i+1)
		if not skip_sound:
			animation.track_insert_key(sound_index, time, {"method": "play_sound", "args": [i, current_char]})

		time += delay

	# Set the final time to the animation
	animation.length = time

	return animation
