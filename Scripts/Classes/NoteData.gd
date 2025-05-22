extends Node
class_name NoteData

## The name of the note: ["left", "down", "center", "up", "right"].
@export var key_name:StringName = "";
## Note type, currently only normal exists.
@export var type:StringName = "normal";
## Note position in the song ms.
@export var time:float = 0.0;
## Events do not matter yet.
#@export var events:Array[StringName] = [];
