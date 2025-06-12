extends Node2D
class_name Character

## The display name of the character.
@export var character_name:String = "";
## The primary color of the character for theming purposes.
@export var character_color:Color = Color.WHITE;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
