extends Node

const MAXAMMO = 6

enum BulletType {
	Normal,
	Richochet,
	Recoil,
	Power,
	Oil,
	Spark
}

var cylinder: Array[BulletType]


func LoadAmmo(bullet) -> void:
	if cylinder.size() < 6:
		cylinder.push_back(bullet)
	else:
		print_debug("Cylinder full")

func Fire() -> void:
	if cylinder.size() > 0:
		#TODO move the firing code to this method
		return cylinder.pop_front()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
