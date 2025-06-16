extends Control

@onready var cl:CanvasLayer = $"main" as CanvasLayer;
@onready var cover:ColorRect = $"main/trans_color" as ColorRect;
@onready var anim:AnimationPlayer = $"main/anim" as AnimationPlayer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fix_scale() -> void:
	if cl != null: 
		cl.scale = Vector2(get_window().content_scale_size.x/640, get_window().content_scale_size.y/360);
		cover.scale = Vector2(get_window().content_scale_size.x/640, get_window().content_scale_size.y/360);
		cover.position.y = -cover.size.y;
		pass
	pass

func get_anim() -> String:
	var canim:String = "default";
	match (get_window().content_scale_size.x/640):
		3: canim = "default3";
	return canim;

func down() -> void:
	fix_scale();
	if anim != null: anim.play(get_anim());
	pass

func up() -> void:
	fix_scale();
	anim.play_backwards(get_anim());
	pass
