extends Node

class_name StoryScript

var dialog := {};
var event := {};

var dialog_lines := 0;
var event_lines := 0;

func _ready() -> void:
    var this = StoryScript;
    script();
    pass

func _process(_delta: float) -> void:
    assert((dialog_lines != event_lines), "Script is not valid!");
    pass

func script():
    pass

## Add a line to the dialog.[br]
##[br]
## [line] - The content or 'voice' line.
func add_line(line := "", counter := dialog_lines):
    dialog.get_or_add(counter, line);
    if counter == dialog_lines:
        dialog_lines += 1;
        counter += 1;


## Add an event.[br]
## If a line already exists on the current line counter, then the line will not be replaced.[br]
## [br]
##[br]
func add_event(_event, counter:=event_lines):
    event_lines += 1;
    event.get_or_add(counter, _event);
    pass
