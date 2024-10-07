extends Node2D

func _close():
	$anim.play("fade_out");
	await $anim.animation_finished;
	LevelManager.trans("Main");

func _on_saveclose_button_up() -> void:
	pass # Replace with function body.


func _on_close_button_up() -> void:
	_close();
	pass # Replace with function body.
