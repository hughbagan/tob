class_name Player extends KinematicBody2D

onready var sprite:Sprite = $Sprite
onready var spr_scale:Vector2 = sprite.scale
onready var col:CollisionShape2D = $CollisionShape2D
onready var jump_area:Area2D = $JumpArea
onready var jump_timer:Timer = $JumpTimer
var tilemap:TileMap
var current_tile_coords:Vector2
var current_tile:int
var level
var speed:float = 75.0
var velocity:Vector2 = Vector2()
var jumping:bool = false


func _physics_process(_delta):
	velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	velocity = move_and_slide(velocity.normalized() * speed)

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	current_tile = tilemap.get_cellv(current_tile_coords)

	if Input.is_action_pressed("jump") and not jumping:
		jump()
	# if not jumping:
	# 	if current_tile >= 5 and current_tile <= 7:
	# 		get_tree().create_timer(1.0, false).connect("timeout", self, "_on_leaf_destroy", [current_tile_coords])
	# 	elif current_tile <= 0:
	# 		get_tree().reload_current_scene()


func jump():
	jumping = true
	jump_timer.start()
	$JumpSFX.play()
	var jump_tween = get_tree().create_tween()
	jump_tween.tween_property(sprite, "scale", spr_scale*1.5, jump_timer.wait_time*0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	jump_tween.chain().tween_property(sprite, "scale", spr_scale, jump_timer.wait_time*0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	col.disabled = true


func _on_JumpTimer_timeout():
	# Landing
	jumping = false
	col.disabled = false
	$landSFX.play()
	for body in jump_area.get_overlapping_bodies():
		body.queue_free()
		jump()


func _on_leaf_destroy(tile_coords:Vector2):
	tilemap.set_cellv(tile_coords, 0)
