extends Node2D

# Scene References
@onready var error_text = $fallback_bg/fallback_text;
@onready var loading_text = $fallback_bg/loading_text;
@onready var main = $main;
@onready var hud = $hud;
@onready var parallax_bg = $fallback_bg/parallax_bg;

# This holds the 
var max_seg : int = 0;
var segment_counter : int = max_seg;

func _init() -> void:
	pass

func _ready() -> void:
	fallback(false);
	pass
	
func _process(delta: float) -> void:
	pass

func fallback(isError : bool = true) -> void:
	parallax_bg.visible = true;
	main.visible = false;
	hud.visible = false;
	if isError:
		error_text.visible = true;
	else:
		loading_text.visible = true;
	pass
