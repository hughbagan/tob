class_name Lamp extends Node2D


func _process(_delta:float):
	if Input.is_action_pressed("bloodvision"):
		$SpriteShaded.show()
		$Light2D.hide()
		$RedLight.show()
	else:
		$SpriteShaded.hide()
		$Light2D.show()
		$RedLight.hide()
