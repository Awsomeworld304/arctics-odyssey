extends Node
# TAC is Text Arctic Chart
# PAC is Packed Arctic Chart
static var _jtypes:PackedStringArray = ["json", "tac"];
static var _btypes:PackedStringArray = ["pac"];

static func is_json_chart(path:String = "") -> bool:
	if path.is_empty(): return false;
	var ext:String = path.get_extension();
	if ext.is_empty(): return false;
	if _jtypes.has(ext) and ((ext != "json") if !Settings.debug else true): return true;
	return false;

static func is_bin_chart(path:String = "") -> bool:
	if path.is_empty(): return false;
	var ext:String = path.get_extension();
	if ext.is_empty(): return false;
	if _btypes.has(ext): return true;
	return false;

class Mod extends Node:
	var characters:Array[Character] = [];
	var stages:Array[Stage] = [];
	var charts:Array[Chart] = [];
	
	func _ready() -> void:
		pass
	pass

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func load_mod() -> Mod:
	var mod:Mod = Mod.new();
	return mod;

func find_songs() -> Dictionary[String, String]:
	var book:Dictionary[String, String] = {};
	var dir:DirAccess = DirAccess.open("user://Mods/Songs");
	if not dir: push_error("ModLoader -> Find Songs: Failed to open mod directory."); return book;
	dir.include_navigational = false;
	dir.include_hidden = false;
	
	for sub:String in dir.get_directories():
		if FileAccess.file_exists("%s/%s/metadata.json" % [dir.get_current_dir(), sub]):
			var json:JSON = JSON.new();
			var song_name:String = json.parse_string(FileAccess.open("%s/%s/metadata.json" % [dir.get_current_dir(), sub], FileAccess.READ).get_as_text())["song"];
			print(ChartMetadata.parse_metadata("%s/%s/metadata.json" % [dir.get_current_dir(), sub]));
			book.get_or_add(song_name, "%s/%s/metadata.json" % [dir.get_current_dir(), sub]);
			if Settings.debug: print("Modloader -> Find Songs: Found valid song with name %s at %s." % [song_name, ("%s/%s" % [dir.get_current_dir(), sub])]);
		pass
	return book;
