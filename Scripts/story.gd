extends Node2D

# Fallback Handlers
@onready var error_text = $fallback_bg/fallback_text;
@onready var loading_text = $fallback_bg/loading_text;

# This holds the 
var max_seg : int = 0;
var segment_counter : int = max_seg;

func _init() -> void:
	pass

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

func fallback(isError : bool = false):
	
	pass
