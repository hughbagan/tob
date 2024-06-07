extends Node


func main_menu_music(toggle:bool):
	if toggle == true:
		if $MainMenuMusic.playing() == false:
			# put tweens here
			$MainMenuMusic.play()
	if toggle == false:
		if $MainMenuMusic.playing() == true:
			# put tweens here
			$MainMenuMusic.stop()


func credits_music(toggle:bool):
	if toggle == true:
		if $CreditsMusic.playing() == false:
			# put tweens here
			$CreditsMusic.play()
	if toggle == false:
		if $CreditsMusic.playing() == true:
			# put tweens here
			$CreditsMusic.stop()


func level_music(toggle:bool):
	if toggle == true:
		if $LevelMusic.playing() == false:
			# put tweens here
			$LevelMusic.play()
	if toggle == false:
		if $LevelMusic.playing() == true:
			# put tweens here
			$LevelMusic.stop()
