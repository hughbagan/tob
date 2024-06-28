class_name Player extends KinematicBody2D

onready var sprite:Sprite = $FlySprite
onready var spr_scale:Vector2 = sprite.scale
onready var col:CollisionShape2D = $CollisionShape2D
onready var jump_area:Area2D = $JumpArea
onready var jump_timer:Timer = $JumpTimer
onready var slay_raycast:RayCast2D = $SlayRaycast
onready var light:Light2D = $Light2D
onready var tilemap:TileMap
onready var level
var current_tile_coords:Vector2
var current_tile:int
var hp:float
var speed:float = 75.0
var velocity:Vector2 = Vector2()
var jumping:bool = false
var attack_range:float = 1.1 # in tilemap cells
var damage:int = 1
var tile_position:Vector2
var jump_rand_list:int
var land_rand_list:int
var footstep_rand_list
var footstep_counter = 0.0
var footstep_frequency = 15 #lower is faster (8ish = Mr. Krabs)
var player_swing_sfx_randi:int
signal new_hp(new_hp)
signal player_die


func _ready() -> void:
	set_hp(hp)


func _physics_process(delta:float) -> void:

	if Input.is_action_pressed("bloodvision"):
		set_hp(hp-0.05)
		$Light2D.hide()
		$RedLight.show()
		if $FlySprite.visible:
			$FlySpriteShaded.show()
			$SpriteShaded.hide()
		else:
			$FlySpriteShaded.hide()
			$SpriteShaded.show()
	else:
		$Light2D.show()
		$RedLight.hide()
		$FlySpriteShaded.hide()
		$SpriteShaded.hide()

	velocity = Vector2()
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	velocity = velocity.normalized()
	slay_raycast.cast_to = velocity * tilemap.cell_size * attack_range

	# Tile centering
	tile_position = ((global_position / (tilemap.cell_size.x*0.5)) + Vector2(1,1))
	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right") and abs(round(tile_position.x) - tile_position.x) > .02:
		velocity.x += round(tile_position.x) - tile_position.x
	if not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down") and abs(round(tile_position.y) - tile_position.y) > .02:
		velocity.y += round(tile_position.y) - tile_position.y

	velocity = move_and_slide(velocity * speed) #used to be velocity.normalized()

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	current_tile = tilemap.get_cellv(current_tile_coords)

	if Input.is_action_just_pressed("jump") and not jumping:
		# First raycast to see if we can hit an enemy
		var collider = slay_raycast.get_collider()
		if collider != null:
			if collider is Enemy:
				collider.hit(self)
				hit_sfx()
				set_hp(hp+3.0)
		else:
			jump()

	# Footsteps
	if MusicMan.player_dead == false:
		if velocity != Vector2(0,0) and not jumping and current_tile != Global.LEVEL_WALL_TILE_ID:
			footstep_counter += delta * 60
			if footstep_counter >= footstep_frequency:
				footstep_sfx()
				footstep_counter = 0.0


func jump() -> void:
	jumping = true
	set_collision_mask_bit(0, 0) # avoid the Level
	set_collision_mask_bit(2, 0) # avoid enemies
	set_collision_layer_bit(1, 0) # enemies avoid the player
	jump_timer.start()
	jump_sfx()
	var jump_tween = get_tree().create_tween()
	jump_tween.tween_property(sprite, "scale", spr_scale*1.5, jump_timer.wait_time*0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	jump_tween.chain().tween_property(sprite, "scale", spr_scale, jump_timer.wait_time*0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	$Sprite.hide()
	$FlySprite.show()


func _on_JumpTimer_timeout() -> void:
	# Landing
	jumping = false
	set_collision_mask_bit(0, 1) # enable level collision
	set_collision_mask_bit(2, 4) # enable player-enemy collision
	set_collision_layer_bit(1, 2) # enable enemy-player collision
	$Sprite.show()
	$FlySprite.hide()
	var bodies = jump_area.get_overlapping_bodies()
	# landing on floor
	if bodies.empty():
		land_sfx()
		footstep_counter = 0
	else:
		# landing on shield
		var shielded = false
		for body in bodies:
			if body.get_name() == "Shield":
				shielded = true
		if shielded:
			jump()
			# sfx?
		else:
			# landing on entity
			for body in bodies:
				if body is Enemy:
					body.hit(self)
					if body.hp > 0:
						jump()
					else:
						set_hp(hp+3.0)
					hit_sfx()


func hit(dmg:float) -> void:
	# Called by hostile bodies upon collision
	set_hp(hp - dmg)


func set_hp(new_hp:float) -> void:
	hp = new_hp
	if hp > 100.0:
		hp = 100.0
	emit_signal("new_hp", new_hp)
	if hp < 0.0:
		emit_signal("player_die")
		MusicMan.player_dead = true


func jump_sfx() -> void:
	if MusicMan.player_dead == false:
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
	if MusicMan.player_dead == false:
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
	if MusicMan.player_dead == false:
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
	if MusicMan.player_dead == false:
		var player_swing_sfx_list = [$SFX/PlayerSwingSFX/PlayerSwingSFX1, $SFX/PlayerSwingSFX/PlayerSwingSFX2, $SFX/PlayerSwingSFX/PlayerSwingSFX3, $SFX/PlayerSwingSFX/PlayerSwingSFX4, $SFX/PlayerSwingSFX/PlayerSwingSFX5]
		var loop_randi_swing
		var loop_bool = true
		while loop_bool:
			loop_randi_swing = randi() % player_swing_sfx_list.size()
			if loop_randi_swing != player_swing_sfx_randi:
				loop_bool = false
		player_swing_sfx_randi = loop_randi_swing
		player_swing_sfx_list[loop_randi_swing].play()
