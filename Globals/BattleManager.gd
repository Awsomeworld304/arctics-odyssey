extends Node

# General
var inBattle = false;

var entities = [
	"player",
	"enemy"
];

# Player
var PlayerHealth = 100;
var PlayerMaxHealth = 100;
var PlayerMana = 50;
var PlayerMaxMana = 50;

# Enemy
var EnemyHealth = 100;
var EnemyMaxHealth = 100;
var EnemyMana = 50;
var EnemyMaxMana = 50;
var isBoss = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func attack():
	pass

func block():
	pass

func add_mana(amount:int, entity:String = "player"):
	pass
	
func add_health(amount:int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
