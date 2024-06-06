class_name Player extends KinematicBody2D

onready var sprite:Sprite = $FlySprite
onready var spr_scale:Vector2 = sprite.scale
onready var col:CollisionShape2D = $CollisionShape2D
onready var jump_area:Area2D = $JumpArea
onready var jump_timer:Timer = $JumpTimer
var tilemap:TileMap
var current_tile_coords:Vector2
var current_tile:int
var level
var hp:float = 100.0
var speed:float = 75.0
var velocity:Vector2 = Vector2()
var jumping:bool = false
var tile_position:Vector2
var jump_rand_list
var land_rand_list
var footstep_rand_list
var footstep_counter = 0.0
var footstep_frequency = 15 #lower is faster (10ish = Mr. Krabs)
signal player_die


func _ready() -> void:
	level.blood_bar.value = hp


func _physics_process(delta) -> void:
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
	velocity = velocity.normalized()

	# Tile centering
	tile_position = ((global_position / (tilemap.cell_size.x*0.5)) + Vector2(1,1)) #/ 2
	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right") and abs(round(tile_position.x) - tile_position.x) > .02:
		velocity.x += round(tile_position.x) - tile_position.x
	if not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down") and abs(round(tile_position.y) - tile_position.y) > .02:
		velocity.y += round(tile_position.y) - tile_position.y

	velocity = move_and_slide(velocity * speed) #used to be velocity.normalized()

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	current_tile = tilemap.get_cellv(current_tile_coords)

	if Input.is_action_pressed("jump") and not jumping:
		jump()

	# Footsteps
	if velocity != Vector2(0,0) and not jumping:
		footstep_counter += delta * 60
		if footstep_counter >= footstep_frequency:
			footstep_sfx()
			footstep_counter = 0.0


func jump() -> void:
	jumping = true
	jump_timer.start()
	jump_sfx()
	var jump_tween = get_tree().create_tween()
	jump_tween.tween_property(sprite, "scale", spr_scale*1.5, jump_timer.wait_time*0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	jump_tween.chain().tween_property(sprite, "scale", spr_scale, jump_timer.wait_time*0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	col.disabled = true
	$Sprite.hide()
	$FlySprite.show()


func _on_JumpTimer_timeout() -> void:
	# Landing
	jumping = false
	col.disabled = false
	$Sprite.show()
	$FlySprite.hide()
	var has_landed_sfx = 1
	for body in jump_area.get_overlapping_bodies():
		body.queue_free()
		hit_sfx()
		jump()
		has_landed_sfx = 0
	if has_landed_sfx == 1:
		land_sfx()
		footstep_counter = 0


func hit(damage:float) -> void:
	hp -= damage
	level.blood_bar.value = hp
	if hp < 0.0:
		emit_signal("player_die")


func jump_sfx() -> void:
	var jump_sounds = [$SFX/JumpSFX/JumpSFX1, $SFX/JumpSFX/JumpSFX2, $SFX/JumpSFX/JumpSFX3]
	var jump_randi
	var rand_loop = true
	while rand_loop:
		jump_randi = randi() % jump_sounds.size()
		if jump_randi != jump_rand_list:
			rand_loop = false
	jump_rand_list = jump_randi
	jump_sounds[jump_randi].play()


func land_sfx() -> void:
	var land_sounds = [$SFX/LandSFX/LandSFX1, $SFX/LandSFX/LandSFX2, $SFX/LandSFX/LandSFX3]
	var land_randi
	var rand_loop = true
	while rand_loop:
		land_randi = randi() % land_sounds.size()
		if land_randi != land_rand_list:
			rand_loop = false
	land_rand_list = land_randi
	land_sounds[land_randi].play()


func footstep_sfx() -> void:
	var footstep_sounds = [$SFX/FootstepSFX/FootstepSFX, $SFX/FootstepSFX/FootstepSFX2, $SFX/FootstepSFX/FootstepSFX3, $SFX/FootstepSFX/FootstepSFX4]
	var footstep_randi
	var rand_loop = true
	while rand_loop:
		footstep_randi = randi() % footstep_sounds.size()
		if footstep_randi != footstep_rand_list:
			rand_loop = false
	footstep_rand_list = footstep_randi
	footstep_sounds[footstep_randi].play()


func hit_sfx() -> void:
	print("Pow!")
