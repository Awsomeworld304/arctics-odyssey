extends AnimatedSprite2D

@onready var curName = self.animation.get_basename();
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.apply_scale(Vector2(0.1,0.1))
	self.position.y = 1000;
	match curName:
		"left":
			self.position.x = $"../left".position.x;
			pass;
		"up":
			self.position.x = $"../up".position.x;
			pass;
		"center":
			self.position.x = 0;
			pass
		"down":
			self.position.x = $"../down".position.x;
			pass;
		"right":
			self.position.x = $"../right".position.x;
			pass;
		_:
			self.position.x = 0;
			pass;
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position.y -= 1000*delta;
	pass
