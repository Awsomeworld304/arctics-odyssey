extends Node
## Event object.
class_name Event

var eventscript:EventScript;

func _load_script(path:String) -> EventScript:
	var scr:EventScript;
	if !ResourceLoader.exists(path, "Script"):
		if !FileAccess.file_exists(path): return scr;
	return scr;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _trigger_event() -> void:
	#eventscript._on_event();
	pass
