extends Node2D

@onready var anim:AnimationPlayer = $anim as AnimationPlayer;
@onready var tabPanels:Array[Panel] = [($"menu/main/Gameplay" as Panel), ($"menu/main/Graphics" as Panel), ($"menu/main/Display" as Panel), ($"menu/main/Input" as Panel)];
@onready var deleteSaveBtn:Button = $"menu/main/Gameplay/DeleteSave" as Button;

#region Save Funcs
func _close() -> void:
	anim.play("fade_out");
	await anim.animation_finished;
	LevelManager.trans("Main");

func _on_saveclose_button_up() -> void:
	var err:Error = Settings._save_settings();
	if err != OK:
		LevelManager.error(error_string(err));
		pass
	pass

func _on_close_button_up() -> void:
	_close();
	pass
#endregion

#region Tab Logic
func _switch_tab(indx:int) -> void:
	var cnt:int=0;
	for i:Panel in tabPanels:
		i.visible = false if cnt != indx else true;
		cnt+=1;
	pass

func _on_settings_tabs_tab_changed(tab:int) -> void:
	_switch_tab(tab);
	pass
#endregion

#region Gameplay
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


func _on_delete_save_button_up() -> void:
	saveClick+=1;
	_delete_save();
	pass # Replace with function body.
#endregion

#region Graphics
@onready var fpsBox:LineEdit = $"menu/main/Graphics/FramerateLabel/Framerate" as LineEdit;
#endregion

#region Display
#endregion

#region Input
var inputs:Array[bool] = [false, false, false, false, false];

@onready var lbl_key_left:Label = $menu/main/Input/left/key_lbl as Label;
@onready var lbl_key_down:Label = $menu/main/Input/down/key_lbl as Label;
@onready var lbl_key_center:Label = $menu/main/Input/center/key_lbl as Label;
@onready var lbl_key_up:Label = $menu/main/Input/up/key_lbl as Label;
@onready var lbl_key_right:Label = $menu/main/Input/right/key_lbl as Label;

func update_key_lbls() -> void:
	var lft:InputEvent = InputMap.action_get_events("left")[0];
	var down:InputEvent = InputMap.action_get_events("down")[0];
	var cntr:InputEvent = InputMap.action_get_events("center")[0];
	var up:InputEvent = InputMap.action_get_events("up")[0];
	var rght:InputEvent = InputMap.action_get_events("right")[0];
	
	lbl_key_left.text = lft.as_text();
	lbl_key_down.text = down.as_text();
	lbl_key_center.text = cntr.as_text();
	lbl_key_up.text = up.as_text();
	lbl_key_right.text = rght.as_text();
	pass

func start_key_grab(key:int) -> void:
	for k:bool in inputs: k = false;
	inputs[key] = true;
	($menu/main/Input/input_screen as PopupMenu).visible = true;
	pass

func set_key(event:InputEvent) -> void:
	($menu/main/Input/input_screen as PopupMenu).visible = false;
	for i:int in range(inputs.size()):
		if inputs[i]:
			inputs[i] = false;
			match i:
				0: 
					InputMap.action_erase_events("left");
					InputMap.action_add_event("left", event);
					pass
				1: 
					InputMap.action_erase_events("down");
					InputMap.action_add_event("down", event);
					pass
				2: 
					InputMap.action_erase_events("center");
					InputMap.action_add_event("center", event);
					pass
				3: 
					InputMap.action_erase_events("up");
					InputMap.action_add_event("up", event);
					pass
				4: 
					InputMap.action_erase_events("right");
					InputMap.action_add_event("right", event);
					pass
				_: push_error("Options -> Input: Unknown key value for bind. (%s)" % i);
				pass
			pass
		pass
		update_key_lbls();
	pass

func _on_lftchange_button_up() -> void:
	start_key_grab(0);
	pass

func _on_dwnchange_button_up() -> void:
	start_key_grab(1);
	pass

func _on_cntchange_button_up() -> void:
	start_key_grab(2);
	pass

func _on_upchange_button_up() -> void:
	start_key_grab(3);
	pass

func _on_rhtchange_button_up() -> void:
	start_key_grab(4);
	pass

func _on_input_screen_window_input(event: InputEvent) -> void:
	if event.device == 0 and event is InputEventKey:
		print("Got valid InputEvent: " + event.to_string());
		set_key(event);
		#($menu/main/Input/input_screen as PopupMenu).visible = false;
		pass
	pass

func _input_ready() -> void:
	update_key_lbls();
	pass

func _input_reset() -> void:
	InputMap.load_from_project_settings();
	pass

func _on_input_defaults_button_up() -> void:
	InputMap.load_from_project_settings();
	pass
#endregion

func _ready() -> void:
	_input_ready();
	pass
