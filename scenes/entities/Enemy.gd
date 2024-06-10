class_name Enemy extends KinematicBody2D

enum STATES {SENTRY, ALERT}
var state = STATES.SENTRY
onready var tilemap
onready var player
onready var sight_timer:Timer = $SightTimer
onready var raycast:RayCast2D = $RayCast2D
onready var agent:NavigationAgent2D = $NavigationAgent2D
onready var boots_sfx_list = [$EnemySFX/EnemyBootsSFX/EnemyBootsSFX1, $EnemySFX/EnemyBootsSFX/EnemyBootsSFX2, $EnemySFX/EnemyBootsSFX/EnemyBootsSFX3, $EnemySFX/EnemyBootsSFX/EnemyBootsSFX4]
onready var armour_sfx_list = [$EnemySFX/EnemyArmourSFX/EnemyArmourSFX1, $EnemySFX/EnemyArmourSFX/EnemyArmourSFX2, $EnemySFX/EnemyArmourSFX/EnemyArmourSFX3, $EnemySFX/EnemyArmourSFX/EnemyArmourSFX4]
onready var enemy_swing_sfx_list = [$EnemySFX/EnemySwingSFX/EnemySwingSFX1, $EnemySFX/EnemySwingSFX/EnemySwingSFX2, $EnemySFX/EnemySwingSFX/EnemySwingSFX3, $EnemySFX/EnemySwingSFX/EnemySwingSFX4, $EnemySFX/EnemySwingSFX/EnemySwingSFX5]
var current_tile_coords:Vector2
var sight_distance:int = 2 # in tiles
var speed:float = 50.0
var damage:float = 0.1
onready var boots_sfx_randi:int = 0
onready var armour_sfx_randi:int = 0
onready var enemy_swing_sfx_randi:int = 0
var enemy_swing_freq = 90
var enemy_swing_counter:float = enemy_swing_freq - 15
var footstep_freq = 25
var footstep_counter:float = 10


func _physics_process(delta:float):
	var velocity:Vector2 = Vector2()
	if Input.is_action_pressed("bloodvision"):
		$RedLight.show()
		$SpriteShaded.show()
	else:
		$RedLight.hide()
		$SpriteShaded.hide()

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	match state:
		STATES.SENTRY:
			# Look for player
			if current_tile_coords.distance_to(player.current_tile_coords) <= sight_distance \
			and sight_timer.is_stopped():
				sight_timer.start()
		STATES.ALERT:
			# Chase player
			agent.set_target_location(player.global_position)
			var dir = position.direction_to(agent.get_next_location())
			velocity = dir * speed
			agent.set_velocity(velocity)
			if not agent.is_navigation_finished():
				velocity = move_and_slide(velocity)
				if abs(velocity.x) > 10 or abs(velocity.y) > 10:
					enemy_footstep_counter(delta)
			for i in get_slide_count():
				var collider = get_slide_collision(i).collider
				if collider == player:
					player.hit(damage) # maybe put on a timer?
					enemy_swing_sfx(delta)
					footstep_counter = footstep_freq / 2


func hit() -> void:
	queue_free()


func _on_SightTimer_timeout():
	raycast.cast_to = raycast.to_local(player.global_position)
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider == player:
		state = STATES.ALERT


func enemy_footstep_counter(_delta):
	footstep_counter += _delta * 60
	if footstep_counter >= footstep_freq:
		enemy_footstep()
		footstep_counter = 0


func enemy_footstep(): #plays footstep at enemy's location
	if MusicMan.player_dead == false:
		# print("clang")
		var loop_randi_boots
		var loop_randi_armour
		var loop_bool = true
		while loop_bool:
			loop_randi_boots = randi() % boots_sfx_list.size()
			if loop_randi_boots != boots_sfx_randi:
				loop_bool = false
		loop_bool = true
		while loop_bool:
			loop_randi_armour = randi() % armour_sfx_list.size()
			if loop_randi_armour != armour_sfx_randi:
				loop_bool = false
		boots_sfx_randi = loop_randi_boots
		armour_sfx_randi = loop_randi_armour
		boots_sfx_list[boots_sfx_randi].play()
		armour_sfx_list[armour_sfx_randi].play()


func enemy_swing_sfx(delta):
	if MusicMan.player_dead == false:
		enemy_swing_counter += delta * 60
		if enemy_swing_counter >= enemy_swing_freq:
			enemy_swing_counter = 0
			var loop_randi_swing
			var loop_bool = true
			while loop_bool:
				loop_randi_swing = randi() % enemy_swing_sfx_list.size()
				if loop_randi_swing != enemy_swing_sfx_randi:
					loop_bool = false
			enemy_swing_sfx_randi = loop_randi_swing
			enemy_swing_sfx_list[loop_randi_swing].play()
