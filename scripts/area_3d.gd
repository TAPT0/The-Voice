extends Area3D

var collected=false

func _on_body_entered(body):
	if body.name=="Player" and not collected:
		collect_tape()
		
func collect_tape():
	#hide the tape
	get_parent().visible=false
	#trap:loud noise
	$"../AudioStreamPlayer3D".play()
	
	#come baby warden 
	var warden=get_tree().root.find_child("Warden",true,false)
	if warden:
		#make him know exactly were we are
		warden.look_at(global_position,Vector3.UP)
		
		#anger timer
		warden.anger_timer=10.0
	#destroy object after sound
	await $"../AudioStreamPlayer3D".finished
	get_parent().queue_free()
