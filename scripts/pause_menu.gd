extends CanvasLayer


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	
func toggle_pause():
	var is_paused=get_tree().paused
	if is_paused:
		#unpuase
		get_tree().paused=false
		visible=false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		#pause
		get_tree().paused=true
		visible=true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_resume_button_pressed():
	toggle_pause()


func _on_exit_button_pressed():
	get_tree().quit()
