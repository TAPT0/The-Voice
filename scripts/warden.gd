extends CharacterBody3D

#tell the warden who to chase
@onready var player_path:NodePath
var player_node

const SPEED = 4.0

func _ready():
	#find the player in the world
	player_node=get_parent().get_node("Player")
		
@warning_ignore("unused_parameter")
func _physics_process(delta):
	if player_node:
		#check if players light is on
		var player_light =player_node.get_node("Camera3D/OmniLight3D")
		
		#If light is bright chase haha
		if player_light.light_energy>0.5:
			#look at the player
			look_at(player_node.global_position,Vector3.UP)
			rotation.x=0
			rotation.z=0
			
			#move to player
			velocity=transform.basis.z*-SPEED
			move_and_slide()

func _on_area_3d_body_entered(body):
	if body.name=="Player":
		#reload the game 
		get_tree().reload_current_scene()
