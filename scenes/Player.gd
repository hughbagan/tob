class_name Player extends KinematicBody2D

var speed:float = 100.0
var velocity:Vector2 = Vector2()

func _physics_process(_delta):
	velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	velocity = move_and_slide(velocity.normalized() * speed)
