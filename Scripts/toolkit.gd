extends Node2D
class_name Toolkit

# ---- Tool Menu ----
@onready var tm_panel:Panel = $"main/tool_menu" as Panel;
@onready var tm_godot_dl_label:Label = $"main/tool_menu/godot/g_dl_label" as Label;
@onready var tm_godot_dl_button:Button = $"main/tool_menu/godot/g_dl_button" as Button;
@onready var tm_godot_dl_progress:ProgressBar = $"main/tool_menu/godot/g_dl_progress" as ProgressBar;

func get_godot_path(zip:bool = false) -> String:
	var path:String = OS.get_executable_path().get_base_dir()
	if OS.has_feature("editor"): path = "user://AO";
	match OS.get_name():
		"Windows":
			path = path.replace("\\", "/");
			path += "/toolkit/godot.exe" + ".zip" if zip else "";
		"Linux":
			path += "/toolkit/godot.x86_64" + ".zip" if zip else "";
		_: return "";
	return path;

func unpack_godot(zip_path:String) -> void:
	var zip:ZIPReader = ZIPReader.new();
	var err:int = zip.open(zip_path);
	if err != OK:
		push_error("Toolkit -> GodotUnpacker: Error in opening ZIP: (%s) %s" % [err, error_string(err)]);
		return;
	print("Toolkit -> GodotUnpacker: Opened ZIP: %s" % zip_path.get_file());
	for file_path:String in zip.get_files():
		var file:FileAccess = FileAccess.open(zip_path.get_base_dir() + "/godot." + file_path.get_extension(), FileAccess.WRITE);
		var buffer:PackedByteArray = zip.read_file(file_path);
		var _b:bool = file.store_buffer(buffer);
		file.close();
		pass
	err = zip.close();
	if err != OK: push_error("Toolkit -> GodotUnpacker: Error in closing ZIP: (%s) %s" % [err, error_string(err)]);

	err = DirAccess.remove_absolute(zip_path);
	print("Toolkit -> GodotUnpacker: Deleted ZIP: %s" % zip_path.get_file());
	if err != OK: push_error("Toolkit -> GodotUnpacker: Error in deleting ZIP: (%s) %s" % [err, error_string(err)]);
	pass

func _ready() -> void:
	# ---- Tool Menu ----
	while tm_godot_dl_button == null or tm_godot_dl_label == null or tm_godot_dl_progress == null:
		await get_tree().process_frame;
		pass

	if !FileAccess.file_exists(get_godot_path()) or not OS.has_feature("editor"):
		tm_godot_dl_button.visible = true;
		tm_godot_dl_label.visible = false;
		tm_godot_dl_progress.visible = false;
		pass
	else:
		tm_godot_dl_button.visible = false;
		tm_godot_dl_label.visible = true;
		tm_godot_dl_progress.visible = false;
		pass

	tm_godot_dl_button.visible = true;
	tm_godot_dl_label.visible = false;
	tm_godot_dl_progress.visible = false;
	pass

func _process(_delta: float) -> void:
	pass

# ---- Tool Menu ----
func get_godot_url() -> String:
	var url:String = "";
	match OS.get_name():
		"Windows": url = "https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_win64.exe.zip";
		"Linux": url = "https://github.com/godotengine/godot/releases/download/4.4-stable/Godot_v4.4-stable_linux.x86_64.zip";
	return url;

func _on_hide_button_up() -> void:
	tm_panel.visible = false;
	pass

func _on_godot_dl_started(total_bytes:int) -> void:
	tm_godot_dl_button.visible = false;
	tm_godot_dl_label.visible = false;
	tm_godot_dl_progress.visible = true;
	tm_godot_dl_progress.value = 0;
	tm_godot_dl_progress.max_value = total_bytes;
	tm_godot_dl_progress.step = 1;
	pass

func _on_godot_dl_progressed(downloaded_bytes:int, _total_bytes:int) -> void:
	tm_godot_dl_progress.value = downloaded_bytes;
	pass

func _on_godot_dl_completed(_result:int, _response_code:int, _headers:PackedStringArray, _body:PackedByteArray) -> void:
	tm_godot_dl_button.visible = false;
	tm_godot_dl_label.visible = true;
	tm_godot_dl_progress.visible = false;
	unpack_godot(get_godot_path(true));
	pass

func _on_g_dl_button_button_up() -> void:
	tm_godot_dl_button.visible = false;
	tm_godot_dl_label.visible = false;
	tm_godot_dl_progress.visible = true;
	var gdl:GodotDownloader = GodotDownloader.new(get_godot_url(), get_godot_path(true));
	self.add_child(gdl);
	var _s:int = gdl.download_started.connect(_on_godot_dl_started);
	_s = gdl.download_progressed.connect(_on_godot_dl_progressed);
	_s = gdl.download_completed.connect(_on_godot_dl_completed);
	gdl.start_download();
	pass

# General


func _on_gen_exit_button_up() -> void:
	LevelManager.reload(true);
	pass


func _on_chart_converter_button_up() -> void:
	($main/convert_chart as Panel).visible = true;
	pass
