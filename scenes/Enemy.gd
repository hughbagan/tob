class_name Enemy extends KinematicBody2D


func _process(_delta):
	if Input.is_action_just_pressed("bloodvision"):
		$Sprite.hide()
		$SpriteShaded.show()
	if Input.is_action_just_released("bloodvision"):
		$Sprite.show()
		$SpriteShaded.hide()
