extends StaticBody3D
#points
@onready var hide_point=$HidePoint
@onready var exit_point=$ExitPoint

var is_occupied =false
var player=null

func interact(user):
	player=user
	
	if not is_occupied:
		#hide the player
		is_occupied=true
		player.hide_in_locker(hide_point.global_position,self)
		
	else:
		#player is visible
		is_occupied=false
		player.exit_locker(exit_point.global_position)
		player=null
