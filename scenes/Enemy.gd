class_name Enemy extends KinematicBody2D

enum STATES {SENTRY, ALERT}
var state = STATES.SENTRY
var level
var tilemap
var player
onready var sight_timer:Timer = $SightTimer
onready var raycast:RayCast2D = $RayCast2D
onready var agent:NavigationAgent2D = $NavigationAgent2D
onready var boots_sfx_list = $EnemySFX/EnemyBootsSFX.get_children()
onready var armour_sfx_list = $EnemySFX/EnemyArmourSFX.get_children()
var current_tile_coords:Vector2
var sight_distance:int = 2 # in tiles
var speed:float = 50.0
var damage:float = 0.1
var boots_sfx_randi
var armour_sfx_randi


func _process(_delta):
	var velocity:Vector2 = Vector2()
	if Input.is_action_just_pressed("bloodvision"):
		$SpriteShaded.show()
	if Input.is_action_just_released("bloodvision"):
		$SpriteShaded.hide()

	current_tile_coords = tilemap.world_to_map(tilemap.to_local(global_position))
	match state:
		STATES.SENTRY:
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
			for i in get_slide_count():
				var collider = get_slide_collision(i).collider
				if collider == player:
					player.hit(damage) # maybe put on a timer?


func _on_SightTimer_timeout():
	raycast.cast_to = raycast.to_local(player.global_position)
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider == player:
		state = STATES.ALERT


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
