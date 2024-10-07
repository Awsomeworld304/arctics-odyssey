class_name DialogBox
extends RichTextLabel

signal typeStart;
#signal typeFinish;

var dialogList:Dictionary = {};
var count:int = 0;
var curText:String = "";
var done:bool = false;

@onready var anim:AnimationPlayer = $anim as AnimationPlayer;

func type() -> void:
	typeStart.emit();
	curText += "[color=gray]ᛜ";
	anim.play("RESET");
	#var tm = Timer.new();
	#tm.start(1);
	#await tm.is_stopped();
	visible_ratio = 0.0;
	if !curText.is_empty():
		#print_debug("curText var: "+curText)
		text = curText;
	#var tween: Tween = create_tween();
	#tween.set_speed_scale(0.8);
	#tween.tween_property(self, "visible_ratio", 1.0, 2.0).from(0.0);
	#await tween.finished;
	anim.play("type");
	await anim.animation_finished;
	anim.play("blink");
	#typeFinish.emit();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING;
	setup();
	pass # Replace with function body.

func setup() -> void:
	dialogList = StoryManager.text;
	count = 0;
	curText = dialogList.get(count);
	type();
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	if dialogList != StoryManager.text:
		dialogList = StoryManager.text;
	
	if Input.is_action_just_pressed("story_next"):
		if !anim.animation_finished && anim.current_animation == "type":
			anim.seek(anim.current_animation_length);
			return;
		if count+1 < dialogList.size():
			count+=1;
			curText=dialogList.get(count);
			type();
	
	if Input.is_action_just_pressed("story_back"):
		if count-1 >= 0:
			count-=1;
			curText=dialogList.get(count);
			type();
		else:
			done=true;
	pass
