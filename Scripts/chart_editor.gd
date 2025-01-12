extends Node2D

@onready var player:AudioStreamPlayer = $"Player" as AudioStreamPlayer;

func _ready() -> void:
	Conductor.player = player;
	var _s:int = Conductor.quarter_will_pass.connect(_on_conductor_quarter_will_pass);
	Conductor.play();
	pass


func _process(_delta: float) -> void:
	if Input.is_action_just_released("debug2"): Conductor.pause();
	pass


func _on_conductor_quarter_will_pass(beat: int) -> void:
	var text:String = "Cached Latency: " + var_to_str(Conductor._cached_latency) + "\n";
	text += "Beat: " + var_to_str((beat % 4) +1) + "\n";
	text += "Measure: " + var_to_str((beat/4)+1) + "\n";
	($"main/debuginfo" as RichTextLabel).text = text;
	pass
