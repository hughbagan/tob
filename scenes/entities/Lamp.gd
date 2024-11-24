class_name Lamp extends Node2D


func _process(_delta:float):
	if Input.is_action_pressed("bloodvision"):
		$SpriteShaded.show()
		$PointLight2D.hide()
		$RedLight.show()
	else:
		$SpriteShaded.hide()
		$PointLight2D.show()
		$RedLight.hide()
