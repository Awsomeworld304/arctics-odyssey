extends Node

class_name StoryScript

var dialog_lines:Dictionary = {};
var event_lines:Dictionary = {};

# Counters
var dialog_counter:int = 0;
var event_counter:int = 0;

## Internal Function
func _ready() -> void:
	var _this:GDScript = StoryScript;
	script();
	pass

func _process(_delta: float) -> void:
	assert((dialog_counter != event_counter), "Script is not valid!");
	pass

## Initial Function
func script() -> void:
	pass

## Add a line to the dialog.[br]
##[br]
## [line] - The content or 'voice' line.[br]
## [step] - The current step the dialog is on.
func add_line(line:String = "", step:int = dialog_counter) -> void:
	dialog_lines.get_or_add(step, line);
	if step == dialog_counter:
		dialog_counter += 1;

func get_line(step:int = dialog_counter) -> void:
	return dialog_lines.get(step);

## Add an event.[br]
## [br]
## [_event] - The function to run as the event.[br]
## Please note that you have to program the event in yourself.[br]
## NOTE: The event is not static here.
func add_event(_event, counter:Dictionary=event_lines) -> void:
	event_counter += 1;
	event_lines.get_or_add(counter, _event);
	pass

func validate() -> void:
	pass

func register() -> void:
	StoryManager._reg_script(self);
	pass
