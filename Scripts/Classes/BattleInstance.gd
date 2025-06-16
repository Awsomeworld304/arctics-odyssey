extends Node
class_name BattleInstance

@export var player:Character;
@export var opponent:Character;

## First turn is always 1.
@export var turn:int = 0:
	get(): return turn + 1;
	set(new_value): turn = new_value - 1;

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass