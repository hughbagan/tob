extends Node

# Functions are named after the called nodes they are replacing, if they are replacing a called node

# Main Menu Music
func MainMenu(toggle:bool, tween_len:float = 0):
	if toggle == true:
		if $MainMenuMusic.playing == false:
			# put tweens here
			$MainMenuMusic.play()
	if toggle == false:
		if $MainMenuMusic.playing == true:
			# put tweens here
			$MainMenuMusic.stop()

# Credits Music
func Credits(toggle:bool, tween_len:float = 0):
	if toggle == true:
		if $CreditsMusic.playing == false:
			# put tweens here
			$CreditsMusic.play()
	if toggle == false:
		if $CreditsMusic.playing == true:
			# put tweens here
			$CreditsMusic.stop()

# Level Music
func level_music(toggle:bool, tween_len:float = 0):
	if toggle == true:
		if $LevelMusic.playing == false:
			# put tweens here
			$LevelMusic.play()
	if toggle == false:
		if $LevelMusic.playing == true:
			# put tweens here
			$LevelMusic.stop()

# Steps Sound (stairs.wav)
func StepsSound():
	$StairsSFX.play()
