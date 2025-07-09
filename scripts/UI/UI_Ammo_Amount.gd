extends Label

#this breaks if i change the layout
@onready var gun : GunController = $"../../Head/Camera3D/Gun"

var last_num

func _ready() -> void:
	print_debug(str(gun))

func _process(delta: float) -> void:
	if gun:
		if gun.cylinder.size() != last_num:
			text = str(gun.cylinder.size())
			last_num = gun.cylinder.size()
