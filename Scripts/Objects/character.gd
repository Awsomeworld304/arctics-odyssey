extends Node2D
class_name Character

## The display name of the character.
@export var character_name:String = "";
## The primary color of the character for theming purposes.
@export var character_color:Color = Color.WHITE;
## Defines the character as a player.
@export var isPlayer:bool = false;
## Names for custom animations.
@export var animation_names:Dictionary[String,String] = {
	"idle": "idle",
	"block": "block",
	"attack": "attack"
};

@onready var sprite:AnimatedSprite2D = $"sprite" as AnimatedSprite2D;

var frames:SpriteFrames;

func _init(name:String = "", color:Color = Color.WHITE, player:bool = false) -> void:
	pass

func _find_anim_paths() -> Dictionary[String,String]:
	var anims:Dictionary[String,String] = animation_names.duplicate();
	
	return anims;

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
