extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Handle it ourselves because 4.2 makes scene changes instant which causes flickering.
func change_level(level : String, object = false):
	var levelPath = "";
	if object:
		levelPath = "res://Objects/" + level + ".tscn";
	else:
		levelPath = "res://Scenes/" + level + ".tscn";
		
	match level:
		"":
			printerr("LevelManager: Invalid args for level!");
			return;
		_:
			if !FileAccess.file_exists(levelPath):
				printerr("LevelManager: Level not found!");
				return;
			print_debug("Loading " + level + "...");
	# Wait for very last frame, to switch it on a good frame!
	await get_tree().process_frame;
	# Changes the scene to the specified level.
	get_tree().change_scene_to_file(levelPath);
	pass
	
func reload(restart = false):
	if get_tree().paused == true:
		get_tree().paused = false;
	if restart:
		await get_tree().process_frame;
		get_tree().change_scene_to_file("res://Scenes/Main.tscn");
		Settings._load_settings();
	else:
		await get_tree().process_frame;
		get_tree().reload_current_scene();

func quit():
	get_tree().quit(0);
