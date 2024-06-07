extends Node

var off_music:AudioStreamPlayer
var player_dead:bool = false
# Functions are named after the called nodes they are replacing, if they are replacing a called node

# Main Menu Music
func MainMenu(toggle:bool, tween_len:float = 0):
	var music = $MainMenuMusic
	var music_vol = music.volume_db
	if toggle == true:
		if music.playing == false:
			tween_music_on(music, tween_len, music_vol)
	if toggle == false:
		if music.playing == true:
			tween_music_off(music, tween_len)

# Credits Music
func Credits(toggle:bool, tween_len:float = 0):
	var music = $CreditsMusic
	var music_vol = music.volume_db
	if toggle == true:
		if music.playing == false:
			tween_music_on(music, tween_len, music_vol)
	if toggle == false:
		if music.playing == true:
			tween_music_off(music, tween_len)

# Level Music
func level_music(toggle:bool, tween_len:float = 0):
	var music = $LevelMusic
	var music_vol = music.volume_db
	if toggle == true:
		if music.playing == false:
			tween_music_on(music, tween_len, music_vol)
	if toggle == false:
		if music.playing == true:
			tween_music_off(music, tween_len)


func tween_music_on(music:AudioStreamPlayer, tween_len:float, music_vol = 0) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(music, "volume_db", music_vol, tween_len)
	music.play()


func tween_music_off(music:AudioStreamPlayer, tween_len:float) -> void:
	var tween = get_tree().create_tween()
	off_music = music # assume only turning one music off at a time
	tween.connect("finished", self, "_on_music_quieted")
	tween.tween_property(music, "volume_db", -60, tween_len)


func _on_music_quieted() -> void:
	off_music.stop()


# Steps Sound (stairs.wav)
func StepsSound(): # Found in MainMenu
	$StairsSFX.play()
