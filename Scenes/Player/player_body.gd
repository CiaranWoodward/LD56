extends Node2D

#Play a random trick animation
func play_random_trick(speed: float):
	
	var rng  := RandomNumberGenerator.new()
	
	#Retrieve trick animation list:
	var trick_list = Array($Tricks.get_animation_list())

	#Remove any non-trick animations from list:
	for i in range(0,len(trick_list))  :
		if trick_list[i] == "RESET" :
			trick_list.remove_at(i)
	
	#Play random trick:
	if is_instance_valid($"../../Audio"):
		$"../../Audio".play_trick()
	$Tricks.play(trick_list[rng.randi_range(0,len(trick_list)-1)],-1,speed)

#Check whether animation is currently playing:			
func animation_status() :
	var status = $Tricks.is_playing()
	return status
