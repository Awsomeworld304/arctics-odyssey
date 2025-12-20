extends Node
class_name BattleInstance

var chart_metadata:ChartMetadata;

@export var player:Character;
@export var opponent:Character;

@export var turn:int = 0;

func _init(chart_info:ChartMetadata = null) -> void:
	if chart_info != null: chart_metadata;
	pass

func _ready() -> void:
	if !chart_metadata:
		push_error("BattleInstance -> Ready: Missing Chart Metadata!");
		return;
	
	pass

func _process(_delta: float) -> void:
	pass
