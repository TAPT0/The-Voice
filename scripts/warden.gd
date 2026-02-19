extends CharacterBody3D
#patrol system 
@onready var patrol_points_parent=get_parent().get_node("PatrolPoints")
var current_patrol_target=null
var is_patrolling=true
#timer anger
var anger_timer=0.0
#fix 
var is_hunting=false
#animation
@onready var anim_player=$warden/AnimationPlayer
#tell the warden who to chase
@onready var player_path:NodePath
var player_node

const SPEED = 20.0

func _ready():
	#wait for map to load
	await get_tree().create_timer(1.0).timeout
	get_new_patrol_point()
	#find the player in the world
	player_node=get_parent().get_node("Player")
		
@warning_ignore("unused_parameter")
func _physics_process(delta):
	if player_node:
		is_hunting=false
		if anger_timer>0.0:
			anger_timer-=delta
			is_hunting=true
			
		#sensors only if not angry
		else:
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
				
			#If light is bright chase haha
			if player_light.light_energy>5.0:
				is_hunting=true
			elif player_light.light_energy>0.6 and distance<25.0:
				is_hunting=true
			elif player_light.light_energy>0.1 and can_see_player:
				is_hunting=true
			elif distance<3.0:
				is_hunting=true
				#smart moving
		if is_hunting:
			$NavigationAgent3D.target_position=player_node.global_position
		else:
			#patrol
			if $NavigationAgent3D.is_navigation_finished():
				velocity=Vector3.ZERO
				if anim_player.current_animation !="Take 001":
					anim_player.play("Take 001",0.5)
				
				#timer
				await get_tree().create_timer(2.0).timeout
				get_new_patrol_point()
				return
			
			#next 
			var next_location=$NavigationAgent3D.get_next_path_position()
			#direction
			var direction =global_position.direction_to(next_location)
			#face that direction smoothly
			var target_rotation=transform.looking_at(next_location,Vector3.UP).basis
			transform.basis=transform.basis.slerp(target_rotation,delta*10.0)
			rotation.x=0
			rotation.z=0
			#move towrads next
			velocity=direction*SPEED
			
			#animation run
			if anim_player.current_animation !="mixamo_com":
				anim_player.play("mixamo_com")
		move_and_slide()

func _on_area_3d_body_entered(body):
	if body.name=="Player":
		#reload the game 
		get_tree().call_deferred("reload_current_scene")

#patrol
func get_new_patrol_point():
	var points=patrol_points_parent.get_children()
	
	var random_point=points.pick_random()
	current_patrol_target=random_point.global_position
	$NavigationAgent3D.target_position=current_patrol_target
	
	is_patrolling=true
