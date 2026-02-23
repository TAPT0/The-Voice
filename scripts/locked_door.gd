extends StaticBody3D


var is_open=false
var is_locked=true

@warning_ignore("unused_parameter")
func interact(user):
	if is_open:
		return
		
	if is_locked:
		var player = get_tree().root.find_child("Player", true, false)
		if player and player.has_key==true:
			is_locked=false
			open_door()
		else:
			$SoundLocked.play()
	else:
		open_door()
func open_door():
	is_open=true
	$SoundOpen.play()
	#swing the door
	var tween=create_tween()
	tween.tween_property(self,"rotation_degrees:y",-90.0,1.0)
