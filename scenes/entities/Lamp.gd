class_name Lamp extends Node2D


func _process(_delta:float):
	if Input.is_action_just_pressed("bloodvision"):
		$SpriteShaded.show()
		$Light2D.hide()
		$RedLight.show()
	if Input.is_action_just_released("bloodvision"):
		$SpriteShaded.hide()
		$Light2D.show()
		$RedLight.hide()
