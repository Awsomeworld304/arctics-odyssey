extends AnimatedSprite2D

@onready var curName = self.animation.get_basename();
signal pressed
signal released
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(curName):
		self.frame = 1;
		pressed.emit();
	elif Input.is_action_just_released(curName):
		self.frame = 0;
		released.emit();
	pass
