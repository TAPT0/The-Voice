extends AnimatableBody3D

var is_moving = false
var is_at_top=false

var bottom_height =0.008
var top_height=24.231
var travel_time=6.0

@warning_ignore("unused_parameter")
func interact(user):
	if is_moving:
		return
	is_moving=true
	$LiftSound.play()
	var tween=create_tween()
	
	if is_at_top:
		#down
		tween.tween_property(self,"global_position:y",bottom_height,travel_time)
	else:
		#up
		tween.tween_property(self,"global_position:y",top_height,travel_time)
		
	#update status
	tween.tween_callback(_on_lift_finished)
func _on_lift_finished():
	is_moving=false
	is_at_top=not is_at_top
	$LiftSound.stop()
