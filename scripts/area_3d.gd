extends Area3D

var collected=false

func interact(user):
	if collected:
		return
	collected=true 
	
	#update the ui
	if user.has_method("collect_tape"):
		user.collect_tape()
	#hide the tape
	get_parent().visible=false
	#trap:loud noise
	$"../AudioStreamPlayer3D".play()

	#come baby warden 
	var warden=get_tree().root.find_child("Warden",true,false)
	if warden:
		#make him know exactly were we are
		warden.is_hunting=true
		warden.anger_timer=10.0
		warden.nav_agent.target_position=global_position
	#destroy object after sound
	await $"../AudioStreamPlayer3D".finished
	get_parent().queue_free()
