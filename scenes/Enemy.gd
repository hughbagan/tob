class_name Enemy extends KinematicBody2D

enum STATES {SENTRY, ALERT}
var state = STATES.SENTRY
var level
var tilemap
var player
onready var sight_timer:Timer = $SightTimer
onready var raycast:RayCast2D = $RayCast2D
var sight_distance:int = 5 # in tiles
var current_tile_coords:Vector2
var boots_sfx_list = [$EnemySFX/EnemyBootsSFX/EnemyBootsSFX1, $EnemySFX/EnemyBootsSFX/EnemyBootsSFX2, $EnemySFX/EnemyBootsSFX/EnemyBootsSFX3, $EnemySFX/EnemyBootsSFX/EnemyBootsSFX4]
var armour_sfx_list = [$EnemySFX/EnemyArmourSFX/EnemyArmourSFX1, $EnemySFX/EnemyArmourSFX/EnemyArmourSFX2, $EnemySFX/EnemyArmourSFX/EnemyArmourSFX3]
var boots_sfx_randi
var armour_sfx_randi


func _process(_delta):
	if Input.is_action_just_pressed("bloodvision"):
		$SpriteShaded.show()
	if Input.is_action_just_released("bloodvision"):
		$SpriteShaded.hide()

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	match state:
		STATES.SENTRY:
			if current_tile_coords.distance_to(player.current_tile_coords) <= 2 \
			and sight_timer.is_stopped():
				sight_timer.start()
		STATES.ALERT:
			# chase the player
			pass


func _on_SightTimer_timeout():
	raycast.cast_to = raycast.to_local(player.global_position)
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider == player:
		state = STATES.ALERT
		print(self, " spotted player!")


func enemy_footstep(): #plays footstep at enemy's location
	var loop_randi_boots
	var loop_randi_armour
	while true:
		loop_randi_boots = randi() % boots_sfx_list.length()
		if loop_randi_boots == boots_sfx_randi:
			break
	while true:
		loop_randi_armour = randi() % boots_sfx_list.length()
		if loop_randi_armour == boots_sfx_randi:
			break
	boots_sfx_randi = loop_randi_boots
	armour_sfx_randi = loop_randi_armour
	boots_sfx_list[boots_sfx_randi].play()
	armour_sfx_list[armour_sfx_randi].play()
