extends Control
class_name GridPanel

## Width of the generated grid.
@export var grid_width:int = 1;
## Height of the generated grid.
@export var grid_height:int = 1;
## First grid color.
@export var pri_grid_color:Color = Color.WEB_GRAY;
## Second grid color.
@export var sec_grid_color:Color = Color.DIM_GRAY;

var _grid_size:Vector2 = Vector2(32,32);

func _ready() -> void:
	update_grid();
	pass

## Updates grid panel. If value is 0, it'll default to the previously set size.
func update_grid(width:int = 0, height:int = 0) -> void:
	if self.get_child_count() > 0:
		for child in self.get_children(): child.queue_free();
		pass
	
	# Vertical Grid
	for i in range(grid_height):
		for j in range(grid_width):
			var panel:ColorRect = ColorRect.new();
		
			panel.set_size(_grid_size);
			panel.position.x = _grid_size.x * j;
			panel.position.y = _grid_size.y * i;
		
			if i % 2 == 0 && j % 2 != 0: panel.color = sec_grid_color;
			elif i % 2 != 0 && j % 2 == 0: panel.color = sec_grid_color;
			else: panel.color = pri_grid_color;
		
			self.add_child(panel);
		pass
	pass
