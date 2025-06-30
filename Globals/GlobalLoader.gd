extends Node

## Fires when an asset gets preloaded: current index, total count, asset path.
signal asset_preloaded(current: int, total: int, path: String, success:bool);
signal finished(total_success: int, total_failure: int);

## Dictionary of assets to preload.[br]
## "path": ["type", cache]
var asset_list:Dictionary = {}

const SUPPORTED_EXTS:Array = [
	"tscn", "scn", "tres", "res", "png", "jpg", "jpeg", "webp", "bmp", "wav", "ogg", "mp3", "ttf", "otf", "fnt", "shader", "gd"
];

const EXCLUDED_EXTS:Array = [
	"dll", "tmp", "import", "exe", "pck", "7z", "zip", "rar", "md", "txt", "csv", "bat", "sh"
];

## Preload all assets.
func preload_all_assets() -> void:
	var total:int = asset_list.keys().size();
	var success_count:int = 0;
	var failure_count:int = 0;
	for i:int in range(total):
		var path:String = (asset_list.keys() as Array[String])[i];
		var type_hint:String = asset_list[path].get("type_hint", "");
		var result:Error = _preload_asset(path, type_hint);
		if result == OK: success_count += 1;
		else: failure_count += 1;
		if Settings.debug: await get_tree().create_timer(0.01).timeout;
		asset_preloaded.emit(i + 1, total, path, (result == OK));
	finished.emit(success_count, failure_count);
	pass

## Preload a single asset, cache it, return error code.
func _preload_asset(asset_path: String, type_hint: String) -> Error:
	var res:Resource = ResourceLoader.load(asset_path, type_hint);
	if res == null:
		push_error("Failed to preload asset: %s (type_hint: %s)" % [asset_path, type_hint]);
		return ERR_CANT_OPEN;
	asset_list[asset_path]["cache"] = res;
	return OK;

func get_cached_asset(asset_path: String) -> Resource:
	if asset_list.has(asset_path):
		return asset_list[asset_path]["cache"];
	return null;

## Scans all files under res:// and returns a list of resource paths.
func scan_all_assets_under_res() -> Array[String]:
	return _scan_dir_for_assets("res://");

## Adds files from dir_path (and subdirectories) to result array.
func _scan_dir_for_assets(dir_path:String) -> Array[String]:
	var result:Array[String] = [];
	var dir:DirAccess = DirAccess.open(dir_path);
	if not dir: return result;
	for file:String in dir.get_files():
		if SUPPORTED_EXTS.has(file.get_extension().to_lower()):
			result.append((dir_path.path_join(file) as String));
		else: continue;
	var subdirs:PackedStringArray = dir.get_directories();
	for subdir:String in subdirs: result.append_array(_scan_dir_for_assets(dir_path.path_join(subdir)));
	return result;

## Scans all assets under "res://" and adds them to asset_list with default values.
func populate_asset_list_from_res() -> void:
	var found_assets:Array[String] = scan_all_assets_under_res()
	for asset_path:String in found_assets:
		var type_hint:String = detect_type_hint(asset_path);
		asset_list[asset_path] = {
			"type_hint": type_hint,
			"cache": null
		}
	pass


func detect_type_hint(asset_path: String) -> String:
	var ext:String = asset_path.get_extension().to_lower();
	match ext:
		"png", "jpg", "jpeg", "webp", "bmp": return "Texture2D";
		"tscn", "scn": return "PackedScene";
		"wav", "ogg", "mp3": return "AudioStream";
		"ttf", "otf", "fnt": return "Font";
		"tres", "res": return ""; # Godot resource, so no idea what it ACUTALLY is.
		"shader": return "Shader";
		"gd": return "Script";
		_: return "" # Unknown resource.
