extends Node

var MusicMan_debug:bool = false

var off_music:AudioStreamPlayer
var player_dead:bool = false

# Main Menu music
func MainMenu(toggle:bool = false, tween_len:float = 0):
	var music = $MainMenuMusic
	_music_changer(toggle, tween_len, music)

# Credits music
func Credits(toggle:bool = false, tween_len:float = 0):
	var music = $CreditsMusic
	_music_changer(toggle, tween_len, music)

# Level music
func level_music(toggle:bool = false, tween_len:float = 0):
	var music = $LevelMusic
	_music_changer(toggle, tween_len, music)

# --------------------------------------------------------------------------
# Toggles the music
func _music_changer(toggle:bool, tween_len:float, music:AudioStreamPlayer):
	var music_vol = music.volume_db
	if toggle == true:
		if music.playing == false:
			tween_music_on(music, tween_len, music_vol)
	elif toggle == false:
		if music.playing == true:
			tween_music_off(music, tween_len)


func tween_music_on(music:AudioStreamPlayer, tween_len:float, music_vol = 0) -> void:
	var tween = get_tree().create_tween()
	music.volume_db = -60
	music.play()
	tween.tween_property(music, "volume_db", music_vol, tween_len)
	if MusicMan_debug == true:
		print("Playing: ", music)


func tween_music_off(music:AudioStreamPlayer, tween_len:float) -> void:
	var tween = get_tree().create_tween()
	off_music = music # assume only turning one music off at a time
	tween.connect("finished", self, "_on_music_quieted")
	tween.tween_property(music, "volume_db", -60, tween_len)


func _on_music_quieted() -> void:
	off_music.stop()
	if MusicMan_debug == true:
		print("Stopped: ", off_music)


# Steps Sound (stairs.wav)
func StepsSound():
	$StairsSFX.play()
	if MusicMan_debug == true:
		print("Playing: ", $StairsSFX)
