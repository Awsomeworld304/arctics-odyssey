class_name NoteGroup
extends Node

# Manually specify strums.
@export var left_strum:AnimatedSprite2D;
@export var down_strum:AnimatedSprite2D;
@export var center_strum:AnimatedSprite2D;
@export var up_strum:AnimatedSprite2D;
@export var right_strum:AnimatedSprite2D;

var notes:Array[Note] = [];

func gen_notes(noteArr:Array[Note]):
	noteArr.sort_custom(func(a, b): return a.time < b.time);
	notes = noteArr;
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
