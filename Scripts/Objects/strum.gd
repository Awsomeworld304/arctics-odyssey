extends AnimatedSprite2D

@export var key_name:StringName;

func _ready() -> void:
	if Settings.debug: ("Strum -> Registering strum key " + key_name + " to group.");
	animation = key_name;
	add_to_group(key_name);
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(key_name): frame = 1;
	elif event.is_action_released(key_name): frame = 0;
	pass
