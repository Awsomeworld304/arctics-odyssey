extends Control

## Prints more detailed information to the screen when enabled.
@export var detailed_information:bool = false;

@onready var cl:CanvasLayer = $"/root/FPS/CanvasLayer" as CanvasLayer;
@onready var data_label:RichTextLabel = $"/root/FPS/CanvasLayer/DebugPanel/RichData" as RichTextLabel;

var memory_enabled:bool = true;

var template:String = "FPS: {fps}{mem}";

func get_mem_formatted() -> String:
	if !memory_enabled: return "";
	var mem:float = (OS.get_static_memory_usage()/1000000);
	return "\nMEM: %s %s" % [snappedf(mem, 0.01), "Mb"] if (mem < 1000) else [snappedf(mem/1000, 0.01), "Gb"];

func get_fps_formatted() -> String:
	var color:String = "white";
	var fps:int = Engine.get_frames_per_second();
	if (fps/Engine.max_fps) <= 0.75: color = "yellow";
	elif (fps/Engine.max_fps) <= 0.5: color = "red";
	var f_str:String = "[color=%s]%s[/color]" % [color, fps];
	return f_str;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_static_memory_usage() <= 0: memory_enabled = false;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Settings.fps_counter: data_label.text = template.format({"fps": get_fps_formatted(), "mem": get_mem_formatted()});
	pass

func fix_scale() -> void:
	cl.scale = Vector2(get_window().content_scale_size.x/640, get_window().content_scale_size.y/360);
	pass
