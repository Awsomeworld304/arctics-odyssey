extends Node2D

@export var error:String = "Unknown Fatal Error!";

@onready var text:RichTextLabel = ($fallback_bg/fallback_text as RichTextLabel);

var error_start:String = "[wave freq=5 amp=25][center]Whoops!\nYou're [i]not[/i] supposed to see [color=red]this![color=purple][bgcolor=black]\n";
var error_end:String = "[/bgcolor][p]\n[center][color=white]Please contact the devs and report this bug, thanks in advance!";

func _ready() -> void:
	self.visible = false;
	($fallback_bg as CanvasLayer).visible = false;
	($fallback_bg/parallax_bg as ParallaxBackground).visible = false;
	pass

func change_error(msg:String="Unknown Fatal Error!") -> void:
	error = msg;
	text.text = error_start + error + error_end;
	self.visible = true;
	($fallback_bg as CanvasLayer).visible = true;
	($fallback_bg/parallax_bg as ParallaxBackground).visible = true;


func _on_exit_button_up() -> void:
	LevelManager.trans("Main");
	self.visible = false;
	($fallback_bg as CanvasLayer).visible = false;
	($fallback_bg/parallax_bg as ParallaxBackground).visible = false;
	pass # Replace with function body.
