extends StaticBody3D

var collected=false

@warning_ignore("unused_parameter")
func interact(user):
	if collected:
		return
	collected=true
	var player= get_tree().root.find_child("Player", true,false)
	#give it to player
	if player and player.has_method("collect_key"):
		player.collect_key()
	#play the pickup sounf
	$AudioStreamPlayer3D.play()
		
	visible=false
	await $AudioStreamPlayer3D.finished
	
	#delete 
	queue_free()
