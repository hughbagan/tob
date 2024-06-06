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
