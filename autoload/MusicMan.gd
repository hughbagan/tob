extends Node

var MusicMan_debug:bool = false

var off_music:AudioStreamPlayer
var player_dead:bool = false #global variable, do not touch! It should always start as 'false'
var vol_debug_list:Array = []
var vol_debug_gc_list:Array = []

# Possible music_ease enums:
# EASE_IN = 0 		slow -> fast (cross-fade out)
# EASE_OUT = 1 		fast -> slow (cross-fade in)
# EASE_IN_OUT = 2 	slow -> fast -> slow
# EASE_OUT_IN = 3 	fast -> slow -> fast
# 					0.5 can be used for a linear ease (constant speed)
# set_ease() method: 	https://docs.godotengine.org/en/3.5/classes/class_scenetreetween.html#class-scenetreetween-method-set-ease
# set_ease() enums: 	https://docs.godotengine.org/en/3.5/classes/class_tween.html#enum-tween-easetype

# ------------------------------------------------------
# Main Menu music
func MainMenu(toggle:bool = true, tween_len:float = 0, music_ease = .5):
	var music = $MainMenuMusic
	_music_changer(toggle, tween_len, music, music_ease)

# Credits music
func Credits(toggle:bool = true, tween_len:float = 0, music_ease = .5):
	var music = $CreditsMusic
	_music_changer(toggle, tween_len, music, music_ease)

# Level music
func level_music(toggle:bool = true, tween_len:float = 0, music_ease = .5):
	var music = $LevelMusic
	_music_changer(toggle, tween_len, music, music_ease)

# -------------------------------------------------------------------------
# Toggles the music
func _music_changer(toggle:bool, tween_len:float, music:AudioStreamPlayer, music_ease):
	var music_vol = music.volume_db
	if toggle == true:
		if music.playing == false:
			tween_music_on(music, tween_len, music_ease, music_vol)
	elif toggle == false:
		if music.playing == true:
			tween_music_off(music, tween_len, music_ease, music_vol)


func tween_music_on(music:AudioStreamPlayer, tween_len:float, music_ease = -1, music_vol = 0) -> void:
	var tween = get_tree().create_tween().set_ease(music_ease)
	music.volume_db = -60
	music.play()
	tween.tween_property(music, "volume_db", music_vol, tween_len)
	if MusicMan_debug == true:
		if music.playing == true:
			print("Playing ", music)
			print("Start-time: ", music.get_playback_position())
			vol_debug_list.append(music)


func tween_music_off(music:AudioStreamPlayer, tween_len:float, music_ease = -1, music_vol = 0) -> void:
	var tween = get_tree().create_tween().set_ease(music_ease)
#	off_music = music # assume only turning one music off at a time
#	tween.connect("finished", self, "_on_music_quieted")
	tween.tween_property(music, "volume_db", -60, tween_len)
	tween.tween_callback(music, "stop")
	yield(tween, "finished")
	music.volume_db = music_vol


#func _on_music_quieted() -> void:
#	off_music.stop()
#	if MusicMan_debug == true:
#		if off_music.playing == false:
#			print("Stopped ", off_music)
#			print("Stop-time: ", off_music.get_playback_position())


# Steps Sound (stairs.wav)
func StepsSound():
	$StairsSFX.play()
	if MusicMan_debug == true:
		print("Playing: ", $StairsSFX, " Clang Clang Clang...")


# Volume debuging
func _on_DebugTimer_timeout():
	if MusicMan_debug == false:
		$VolumeDebugTimer.stop()
	# prints volume
	elif vol_debug_list.size() != 0:
		for i in range(vol_debug_list.size()):
			print("Volume of ", vol_debug_list[i], ": ", vol_debug_list[i].volume_db)
			if vol_debug_list[i].volume_db == -50:
				vol_debug_gc_list.append(i)
	
	# removes silent stuff from print list
	if vol_debug_gc_list.size() != 0:
		vol_debug_gc_list.invert()
		print(vol_debug_gc_list)
		for i in vol_debug_gc_list:
			print("Removed ", vol_debug_list[i], " from vol_debug_list")
			vol_debug_list.remove(vol_debug_gc_list[i])
		vol_debug_gc_list = []
