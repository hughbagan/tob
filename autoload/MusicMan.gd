extends Node

onready var tween = get_tree().create_tween().parallel()
# Functions are named after the called nodes they are replacing, if they are replacing a called node

# Main Menu Music
func MainMenu(toggle:bool, tween_len:float = 0):
	var music = $MainMenuMusic
	if toggle == true:
		if music.playing == false:
			tween.tween_property(music, "volume_db", 0, tween_len)
			music.play()
	if toggle == false:
		if music.playing == true:
			tween.tween_property(music, "volume_db", -60, tween_len)
			yield(tween, "finished")
			music.stop()

# Credits Music
func Credits(toggle:bool, tween_len:float = 0):
	var music = $CreditsMusic
	if toggle == true:
		if music.playing == false:
			tween.tween_property(music, "volume_db", 0, tween_len)
			music.play()
	if toggle == false:
		if music.playing == true:
			tween.tween_property(music, "volume_db", -60, tween_len)
			music.stop()

# Level Music
func level_music(toggle:bool, tween_len:float = 0):
	var music = $LevelMusic
	if toggle == true:
		if music.playing == false:
			tween.tween_property(music, "volume_db", 0, tween_len)
			music.play()
	if toggle == false:
		if music.playing == true:
			tween.tween_property(music, "volume_db", -60, tween_len)
			music.stop()

# Steps Sound (stairs.wav)
func StepsSound(): # Found in MainMenu
	$StairsSFX.play()

func StairSound(): # Found in Level
	StepsSound()
