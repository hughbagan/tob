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
var jump_rand_list



func _physics_process(_delta):
	velocity = Vector2()
	if not Input.is_action_pressed("bloodvision"):
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	current_tile = tilemap.get_cellv(current_tile_coords)
	
	print((global_position.x - round(global_position.x)) / 2)
	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"): #and stepify(global_position.x, 0.01) != 0:
		velocity.x += ((global_position.x - round(global_position.x)) / 2)
	if not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down"): #and stepify(global_position.y, 0.01) != 0:
		velocity.y += ((global_position.y - round(global_position.y)) / 2)
		
	velocity = move_and_slide(velocity.normalized() * speed)
	
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
	jump_sfx()
	var jump_tween = get_tree().create_tween()
	jump_tween.tween_property(sprite, "scale", spr_scale*1.5, jump_timer.wait_time*0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	jump_tween.chain().tween_property(sprite, "scale", spr_scale, jump_timer.wait_time*0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	col.disabled = true


func _on_JumpTimer_timeout():
	# Landing
	jumping = false
	col.disabled = false
	for body in jump_area.get_overlapping_bodies():
		body.queue_free()
		jump()


func _on_leaf_destroy(tile_coords:Vector2):
	tilemap.set_cellv(tile_coords, level.LEVEL_FLOOR_TILE_ID)


func jump_sfx():
	var jump_sounds = [$SFX/JumpSFX/JumpSFX1, $SFX/JumpSFX/JumpSFX2, $SFX/JumpSFX/JumpSFX3]
	var jump_randi
	var rand_loop = true
	while rand_loop:
		jump_randi = randi() % jump_sounds.size()
		if jump_randi != jump_rand_list:
			rand_loop = false
	jump_rand_list = jump_randi
	jump_sounds[jump_randi].play()


func land_sfx():
	$SFX/LandSFX.play()
