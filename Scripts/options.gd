extends Node2D

@onready var anim:AnimationPlayer = $anim as AnimationPlayer;
@onready var tabPanels:Array[Panel] = [($"menu/main/Gameplay" as Panel), ($"menu/main/Graphics" as Panel), ($"menu/main/Display" as Panel), ($"menu/main/Input" as Panel)];
@onready var deleteSaveBtn:Button = $"menu/main/Gameplay/DeleteSave" as Button;

# -- GRAPHICS --
@onready var fpsBox:LineEdit = $"menu/main/Graphics/FramerateLabel/Framerate" as LineEdit;

func _close() -> void:
	anim.play("fade_out");
	await anim.animation_finished;
	LevelManager.trans("Main");

func _on_saveclose_button_up() -> void:
	pass


func _on_close_button_up() -> void:
	_close();
	pass

func _switch_tab(indx:int) -> void:
	var cnt:int=0;
	for i:Panel in tabPanels:
		i.visible = false if cnt != indx else true;
		cnt+=1;
	pass

var saveClick:int = 0;
func _delete_save() -> void:
	if saveClick == 1:
		deleteSaveBtn.text = "You sure?";
	elif  saveClick == 2:
		deleteSaveBtn.text = "Save deleted.";
		deleteSaveBtn.release_focus();
		await get_tree().create_timer(2).timeout;
		deleteSaveBtn.text = "Delete Save";
		saveClick = 0;
	pass

func _on_settings_tabs_tab_changed(tab:int) -> void:
	_switch_tab(tab);
	pass


func _on_delete_save_button_up() -> void:
	saveClick+=1;
	_delete_save();
	pass # Replace with function body.

func _ready() -> void:
	# -- Graphics --
	pass