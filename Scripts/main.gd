extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		$DevMenu.visible = !$DevMenu.visible;
	pass


func _on_start_button_up() -> void:
	LevelManager.change_level("stage");
	pass # Replace with function body.


func _on_opt_button_up() -> void:
	pass # Replace with function body.


func _on_quit_button_up() -> void:
	$anim.play("fade_out");
	await $anim.animation_finished;
	LevelManager.quit();
	pass # Replace with function body.
