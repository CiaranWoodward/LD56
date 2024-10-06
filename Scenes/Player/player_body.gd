extends Node2D

#Play a random trick animation
func play_random_trick():
	
	var rng  := RandomNumberGenerator.new()
	
	#Retrieve trick animation list:
	var trick_list = Array($Tricks.get_animation_list())

	#Remove any non-trick animations from list:
	for i in range(0,len(trick_list))  :
		if trick_list[i] == "RESET" :
			trick_list.remove_at(i)
	
	#Play random trick:
	$Tricks.play(trick_list[rng.randi_range(0,len(trick_list)-1)])

#Check whether animation is currently playing:			
func animation_status() :
	var status = $Tricks.is_playing()
	return status
