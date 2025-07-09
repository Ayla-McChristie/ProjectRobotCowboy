extends BoxContainer

@export var EMPTY_COLOR : Color
@export var REG_COLOR : Color
@export var BLAST_COLOR : Color
@export var RICOCHET_COLOR : Color

@onready var gun : GunController = $"../../Head/Camera3D/Gun"
@onready var box1 : ColorRect = $box1
@onready var box2 : ColorRect = $box2
@onready var box3 : ColorRect = $box3
@onready var box4 : ColorRect = $box4
@onready var box5 : ColorRect = $box5
@onready var box6 : ColorRect = $box6

var boxes : Array[ColorRect]
var num_of_bullets

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boxes = [box1, box2, box3, box4, box5, box6]
	num_of_bullets = 7

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if num_of_bullets != gun.cylinder.size():
		num_of_bullets = gun.cylinder.size()
		for i in gun.cylinder.size():
			boxes[i].color = _color_pick(gun.cylinder[i])
			
		for i in range(gun.cylinder.size(), 6):
			boxes[i].color = EMPTY_COLOR
			
func _color_pick(bullet_type : Global.BulletType) -> Color:
	match  bullet_type:
		Global.BulletType.Normal:
			return REG_COLOR
		Global.BulletType.Blast:
			return BLAST_COLOR
		Global.BulletType.Richochet:
			return RICOCHET_COLOR

	return EMPTY_COLOR
