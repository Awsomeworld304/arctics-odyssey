extends Control

@onready var stat_label:Label = $"CanvasLayer/loading_stat" as Label;
@onready var path_label:Label = $"CanvasLayer/loading_stat_path" as Label;
@onready var debug_stat:Label = $"CanvasLayer/debug_stat" as Label;
@onready var preloadbar:ProgressBar = $"CanvasLayer/preloadbar" as ProgressBar;

func _on_asset_load(curr:int, total:int, path:String, success:bool) -> void:
	preloadbar.max_value = total;
	preloadbar.value = curr;
	stat_label.text = "[%s / %s]" % [curr, total];
	path_label.text = path;
	pass

func _ready() -> void:
	GlobalLoader.asset_preloaded.connect(_on_asset_load);
	GlobalLoader.finished.connect(_on_completion);
	GlobalLoader.populate_asset_list_from_res();
	GlobalLoader.preload_all_assets();
	pass

func _process(delta: float) -> void:
	pass

func _on_completion(succ:int, fail:int) -> void:
	if Settings.debug: debug_stat.text = "%s out of %s\nTotal of %s fails." % [succ, preloadbar.max_value, fail];
	await get_tree().create_timer(5).timeout;
	LevelManager.load_scene("Main");
	pass
