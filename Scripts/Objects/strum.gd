extends AnimatedSprite2D

@export var key_name:StringName;
@onready var point:Node2D = $"point" as Node2D;

signal pressed;
signal released;

func _ready() -> void:
	print("Strum -> Registering strum key " + key_name + " to group.");
	animation = key_name;
	add_to_group(key_name);
	pass


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(key_name):
		pressed.emit();
		frame = 1;
	elif Input.is_action_just_released(key_name):
		released.emit();
		frame = 0;
	pass


## Have either note or strum track when the note gets pressed vis ms timing from the center point of the note!!!
