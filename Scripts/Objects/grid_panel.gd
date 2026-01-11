@tool
extends Control
class_name GridPanel

## Width of the generated grid.
@export var grid_width:int = 1:
	set(new_width):
		grid_width = new_width;
		update_grid();
		pass

## Height of the generated grid.
@export var grid_height:int = 1:
	set(new_height):
		grid_height = new_height;
		update_grid();
		pass

@export var grid_width_center:bool = false:
	set(value):
		grid_width_center = value;
		update_grid();
		pass

## First grid color.
@export var grid_color:Color = Color.WEB_GRAY;
## Second grid color.
@export var grid_color_sec:Color = Color.DIM_GRAY;
## The offset of each tile.
@export var tile_offset:Vector2 = Vector2(2,0);
## The snap for the note placement.
@export var note_snap:float = 4;

var _tile_size:Vector2i = Vector2i(32,32);

func _ready() -> void:
	update_grid();
	if Engine.is_editor_hint():
		update_grid();
	pass

func _draw() -> void:
	pass

func sec_to_px(time:float) -> float:
	return time * (Conductor.bpm/60) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func px_to_sec(px:float) -> float:
	return px / (Conductor.bpm/60) / (Conductor._offset_scroll_modifier * Conductor.scroll_speed);

func beat_to_sec(beats:float) -> float:
	print(((beats * 60.0) / Conductor.bpm))
	return (beats * 60.0) / Conductor.bpm;

func update_grid_size(beat_snap:float = 4.0) -> void:
	note_snap = beat_snap;
	self.tile_offset.y = (Conductor.get_beat_time() * (float(Conductor.scroll_speed) * Conductor._offset_scroll_modifier)) * (1.0 / beat_snap);
	self.grid_height = floori(Conductor._num_beats_in_song * beat_snap);
	pass

## Updates grid panel. If value is 0, it'll default to the previously set size.
func update_grid(_width:int = 0, _height:int = 0) -> void:
	if self.get_child_count() > 0:
		for child:Node in self.get_children(): child.queue_free();
		pass

	# Vertical Grid
	for i:int in range(grid_height + note_snap):
		# H Grid
		for j:int in range(grid_width):
			"""
			if i == 0:
				var wpanel:ColorRect = ColorRect.new();
				wpanel.name = "grid_panel_" + str(i) + "_" + str(j);
				wpanel.set_size(_tile_size);
				wpanel.position.x = (_tile_size.x + tile_offset.x) * j;
				wpanel.position.y = (_tile_size.y + tile_offset.y) * -1;
				wpanel.color = Color.from_string("470606", Color.WEB_MAROON);
				self.add_child(wpanel);
				pass
			"""
			
			var panel:ColorRect = ColorRect.new();
			panel.name = "grid_panel_" + str(i) + "_" + str(j);

			panel.set_size(Vector2i(_tile_size.x, 4));
			panel.position.x = (_tile_size.x + tile_offset.x) * j;
			panel.position.y = sec_to_px(beat_to_sec(i) * (1.0/note_snap));
			
			#if i % 2 == 0 && j % 2 != 0: panel.color = grid_color_sec;
			#elif i % 2 != 0 && j % 2 == 0: panel.color = grid_color_sec;
			#else: panel.color = grid_color;
			if !Engine.is_editor_hint():
				if i >= grid_height: panel.color = Color.RED;
				elif i % (Conductor.curr_time_signature.numerator * floori(note_snap)) == 0:
					panel.color = grid_color_sec;
				else: panel.color = grid_color;
			else:
				if i % 4 == 0:
					panel.color = grid_color_sec;
				elif i >= grid_height: panel.color = Color.RED;
				else: panel.color = grid_color;
				pass

			self.add_child(panel);

			if grid_width == 5:
				match j:
					0: panel.add_to_group("g_left");
					1: panel.add_to_group("g_down");
					2: panel.add_to_group("g_center");
					3: panel.add_to_group("g_up");
					4: panel.add_to_group("g_right");
					pass
		pass
	pass

func make_grid() -> void:
	var song_measures:int = Conductor._num_beats_in_song / Conductor.curr_time_signature.numerator;
	var time_per_measure:float = (Conductor.curr_time_signature.numerator / Conductor.bpm) * 60;
	var dist:int = time_per_measure * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);
	pass

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return;
	self.position.y = -16 + (-Conductor.position) * (Conductor.bpm / 60.0) * (Conductor._offset_scroll_modifier * Conductor.scroll_speed);
	pass
