extends Node2D

@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
	DisplayServer.window_set_size(Vector2i(640, 360), 0);
	DisplayServer.window_set_position(Vector2i(1920,320), 0);
	Conductor.player = player;
	var _s:int = Conductor.sixteenth_will_pass.connect(_pass);
	Conductor.play();
	pass

var text:String = "";
func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug2"): Conductor.pause();
	pass


func _pass(beat: int, fract:int) -> void:
	text = "Cached Latency: " + var_to_str(Conductor._cached_latency) + "\n";
	text += "Measure: " + var_to_str((beat/4)+1) + "\n";
	text += "Beat: " + var_to_str((beat % 4) +1) + "\n";
	text += "Step: " + var_to_str((((beat%4)*4)+fract) +1) + "\n";
	($"main/debuginfo" as RichTextLabel).text = text;
	pass
