extends AnimatedSprite2D
class_name Strum

@export var key_name:StringName;
@export var bot_input:bool = false;

func _ready() -> void:
	if Settings.debug: print("Strum -> Registering strum key " + key_name + " to group.");
	animation = key_name;
	add_to_group(key_name);
	pass

func toggle_bot() -> void:
	bot_input = !bot_input;
	if bot_input:
		remove_from_group(key_name);
		add_to_group("bot_" + key_name);
		set_process_input(false);
		pass
	else:
		remove_from_group("bot_" + key_name);
		add_to_group(key_name);
		set_process_input(true);
		pass
	pass

func _input(event: InputEvent) -> void:
	if !bot_input:
		if event.is_action_pressed(key_name): frame = 1;
		elif event.is_action_released(key_name): frame = 0;
	pass

func _process(delta: float) -> void:
	if !is_processing_input() or bot_input:
		if Input.is_action_pressed("bot_" + key_name): frame = 1;
		elif Input.is_action_just_released("bot_" + key_name): frame = 0;
	pass
