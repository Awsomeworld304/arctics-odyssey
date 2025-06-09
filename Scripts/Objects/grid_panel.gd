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

## First grid color.
@export var grid_color:Color = Color.WEB_GRAY;
## Second grid color.
@export var grid_color_sec:Color = Color.DIM_GRAY;
## The offset of each tile.
@export var tile_offset:Vector2i = Vector2i(2,0);
## The snap for the note placement.
@export var note_snap:int = 4;

var _tile_size:Vector2i = Vector2i(32,32);

func _ready() -> void:
	update_grid();
	if Engine.is_editor_hint():
		update_grid();
	pass

func _draw() -> void:
	pass

## Updates grid panel. If value is 0, it'll default to the previously set size.
func update_grid(width:int = 0, height:int = 0) -> void:
	if self.get_child_count() > 0:
		for child in self.get_children(): child.queue_free();
		pass
	
	# Vertical Grid
	for i in range(grid_height):
		# H Grid
		for j in range(grid_width):
			
			if i == 0:
				var panel:ColorRect = ColorRect.new();
				panel.set_size(_tile_size);
				panel.position.x = (_tile_size.x + tile_offset.x) * j;
				panel.position.y = (_tile_size.y + tile_offset.y) * -1;
				panel.color = Color.from_string("470606", Color.WEB_MAROON);
				self.add_child(panel);
				pass
			
			var panel:ColorRect = ColorRect.new();
		
			panel.set_size(_tile_size);
			panel.position.x = (_tile_size.x + tile_offset.x) * j;
			panel.position.y = (_tile_size.y + tile_offset.y) * i;
		
			if i % 2 == 0 && j % 2 != 0: panel.color = grid_color_sec;
			elif i % 2 != 0 && j % 2 == 0: panel.color = grid_color_sec;
			else: panel.color = grid_color;
			
			#var v:VisibleOnScreenEnabler2D = VisibleOnScreenEnabler2D.new();
			#v.rect = panel.get_rect();
			#v.enable_node_path = NodePath(panel.get_path());
			#panel.add_child(v);
			panel.add_child((VisibleOnScreenEnabler2D.new()));
			(panel.get_child(0) as VisibleOnScreenEnabler2D).rect.size = panel.size - Vector2(2,2);
			(panel.get_child(0) as VisibleOnScreenEnabler2D).rect.position += (panel.get_rect().size/2);
			
			if grid_width == 5:
				match j:
					0: panel.add_to_group("g_left");
					1: panel.add_to_group("g_down");
					2: panel.add_to_group("g_center");
					3: panel.add_to_group("g_up");
					4: panel.add_to_group("g_right");
					pass
			self.add_child(panel);
		pass
	pass

func _process(delta: float) -> void:
		pass
