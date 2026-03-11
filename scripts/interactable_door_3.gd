extends StaticBody3D

var is_open=false
var tween:Tween

@warning_ignore("unused_parameter")
func interact(user):
	if tween and tween.is_running():
		return
	is_open=not is_open
	tween=create_tween()
	
	if is_open:
		#swing the door 90 degres
		tween.tween_property(self,"rotation_degrees:y",0,0.5)
	else:
		#swing back to 0 degres
		tween.tween_property(self,"rotation_degrees:y",90.0,0.5)
