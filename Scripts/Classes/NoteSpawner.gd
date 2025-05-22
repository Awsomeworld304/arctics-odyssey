#class_name NoteSpawner
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func sec_to_px(note:Note) -> int:
	return note.data.time * (Conductor.bpm/60) * Conductor.scroll_speed;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
