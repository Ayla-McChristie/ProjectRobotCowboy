extends Camera3D

var Ray_Range = 2000

func _input(event: InputEvent):
	if event.is_action_pressed("primary_fire"):
		pass

func Get_Camera_Collision():
	var Centre = get_viewport().get_size()/2
