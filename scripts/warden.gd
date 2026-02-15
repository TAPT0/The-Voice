extends CharacterBody3D

#tell the warden who to chase
@onready var player_path:NodePath
var player_node

const SPEED = 30.0

func _ready():
	#find the player in the world
	player_node=get_parent().get_node("Player")
		
@warning_ignore("unused_parameter")
func _physics_process(delta):
	if player_node:
		var distance=global_position.distance_to(player_node.global_position)
		#check if players light is on
		var player_light =player_node.get_node("Camera3D/OmniLight3D")
		#eyes
		var warden_eyes=global_position+Vector3(0,1.5,0)
		var player_eyes=player_node.global_position+Vector3(0,1.5,0)
		#laser raycast
		var space_state=get_world_3d().direct_space_state
		var query=PhysicsRayQueryParameters3D.create(warden_eyes,player_eyes)
		query.exclude=[self.get_rid()]
		
		var result=space_state.intersect_ray(query)
		
		var can_see_player=false
		if result and result.collider==player_node:
			can_see_player=true
			
		var is_hunting=false
		#If light is bright chase haha
		if player_light.light_energy>5.0:
			is_hunting=true
		elif player_light.light_energy>0.6 and distance<25.0:
			is_hunting=true
		elif player_light.light_energy>0.1 and can_see_player:
			is_hunting=true
		elif distance<3.0:
			is_hunting=true
		#look at the player
		print("Light:",player_light.light_energy,"|Dist:",distance,"|See:",can_see_player)
		if is_hunting:
			look_at(player_node.global_position,Vector3.UP)
			rotation.x=0
			rotation.z=0
			
			#move to player
			velocity=transform.basis.z*-SPEED
		else:
			velocity=Vector3.ZERO
		move_and_slide()

func _on_area_3d_body_entered(body):
	if body.name=="Player":
		#reload the game 
		get_tree().call_deferred("reload_current_scene")
