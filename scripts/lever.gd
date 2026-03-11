extends StaticBody3D


@export var elevator_node:Node3D
@onready var anim_player=find_child("AnimationPlayer",true,false)

var is_pulled=false
func interact(user):
	if is_pulled:
		return
	is_pulled=true
	#animation
	if anim_player and anim_player.has_animation("Cube_001|CubeAction_001"):
		anim_player.play("Cube_001|CubeAction_001")
	
	if elevator_node:
		if elevator_node.has_method("interact"):
			elevator_node.interact(user)
	await get_tree().create_timer(1.0).timeout
