extends CharacterBody3D
#step sound
var step_timer=0.0
#setting
var WALK_SPEED=3.0
var RUN_SPEED=6.0
var HEAR_DISTANCE=15.0
var THRESHOLD_LOUD=-15.0
var THRESHOLD_WHISPER=-50.0
#jumpscare
var is_jumpscaring=false
#patrol system
@onready var patrol_points_parent=get_parent().get_node("PatrolPoints")
@onready var nav_agent=$NavigationAgent3D
@onready var anim_player=$warden/AnimationPlayer
#tell the earden who to chase
var player_node
var is_hunting=false
var anger_timer=0.0
var wait_timer=0.0
func _ready():
	#wait 
	await get_tree().create_timer(1.0).timeout
	player_node=get_parent().get_node("Player")
	get_new_patrol_point()
@warning_ignore("unused_parameter")
func _physics_process(delta):
	if not player_node or player_node.is_dead:
		return
	if is_jumpscaring:
		return
		
	var distance=global_position.distance_to(player_node.global_position)
	#teleport
	if distance>30.0 and not player_node.is_hidden:
		ghost_teleport()
		return
	#kill player
	if distance<1.5 and not player_node.is_hidden:
		if player_node.has_method("trigger_jumpscare"):
			var face_poss=global_position+Vector3(0,1.2,0)
			player_node.trigger_jumpscare(face_poss)
		velocity=Vector3.ZERO
		#stop animation
		if anim_player.current_animation !="Take 001":
			anim_player.play("Take 001")
		return
	#mic
	if not player_node.is_hidden:
		var mic_bus_index=AudioServer.get_bus_index("MicInput")
		var volume_db=AudioServer.get_bus_peak_volume_left_db(mic_bus_index,0)
		#hear loud 
		if volume_db>THRESHOLD_LOUD:
			is_hunting=true
			anger_timer=5.0
		#hear whisper
		elif volume_db>THRESHOLD_WHISPER and distance<HEAR_DISTANCE:
			is_hunting=true
			anger_timer=5.0
	#eyes and light
	var player_light=player_node.get_node("Camera3D/OmniLight3D")
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
	#check vision
	if not player_node.is_hidden:
		if can_see_player:
			if player_light.light_energy>0.1 or distance<10.0:
				is_hunting=true
				anger_timer=5.0
	else:
		is_hunting=false
	#timer anger and koud
	if is_hunting:
		nav_agent.target_position=player_node.global_position
		if player_node.is_hidden:
			is_hunting=false
	elif anger_timer>0.0:
		anger_timer-=delta
	else:
		#patorl
		if nav_agent.is_navigation_finished():
			get_new_patrol_point()
	#smart moving
	var current_speed=WALK_SPEED
	if is_hunting or anger_timer>0.0:
		current_speed=RUN_SPEED
	
	var next_location=nav_agent.get_next_path_position()
	var direction=global_position.direction_to(next_location)
	direction.y=0.0
	direction=direction.normalized()
	#fix glitvh
	if global_position.distance_to(next_location)>0.5:
		#face that direction smoothly
		var look_target=Vector3(next_location.x,global_position.y,next_location.z)
		if global_position.distance_to(look_target)>0.05:
			var target_rotation=transform.looking_at(look_target,Vector3.UP).basis
			transform.basis=transform.basis.slerp(target_rotation,delta*8.0)
		rotation.x=0
		rotation.z=0
		velocity.x=direction.x*current_speed
		velocity.z=direction.z*current_speed
		
		#animatioon run
		if anim_player.current_animation !="mixamo_com":
			anim_player.play("mixamo_com")
		#footsetp 
		step_timer-=delta
		if step_timer<=0.0:
			$FootstepSound.pitch_scale=randf_range(0.8,1.2)
			$FootstepSound.play()
			
			if current_speed==RUN_SPEED:
				step_timer=0.35
			else:
				step_timer=0.65
	else:
		velocity.z=0.0
		velocity.z=0.0
		if anim_player.current_animation !="Take 001":
			anim_player.play("Take 001",0.5)
	if not is_on_floor():
		velocity.y -=9.8*delta
	move_and_slide()
func _on_area_3d_body_entered(body):
	if body.name=="Player":
		#reload the game
		get_tree().call_deferred("reload_current_scene")
		
		#patrol
func get_new_patrol_point():
	var points=patrol_points_parent.get_children()
	if points.size()>0:
		var random_point=points.pick_random()
		nav_agent.target_position=random_point.global_position

func ghost_teleport():
	#spawn points
	var spawn_nodes=get_parent().get_node("SpawnPoints").get_children()
	if spawn_nodes.size()==0:
		return
		
	#randomize
	var random_spot=spawn_nodes.pick_random()
	
	#teleport 
	global_position=random_spot.global_position
	#no yaadasht
	is_hunting=false
	anger_timer=0.0
	wait_timer=2.0
	$NavigationAgent3D.target_position=global_position
