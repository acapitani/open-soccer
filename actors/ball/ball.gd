extends KinematicBody2D

const OUTOFGAME = 0
const INGAME = 1
const ISOUT = 2
const INGOAL = 3
#const ATTACHED_TO_PLAYER = 4

const A_FRICTION = 16
const T_FRICTION = 50
const G = 9.8

var anim_nxt = ""
var anim_cur = ""

var player = null
var last_player_id = -1
var last_team_id = -1
var speed_up = 0
var speed = 0
var T = 0.0
var H = 0.0
var direction = Vector2()
var max_H = 0.0
var limit_H = 0.0
var status = OUTOFGAME
var startpos = Vector2()

#var speed = 300
var friction = 0.05
var acceleration = 1.0
var velocity = Vector2.ZERO
var first_bounce = true


# Called when the node enters the scene tree for the first time.
func _ready():
	player = null
	last_player_id = -1
	last_team_id = -1
	speed_up = 0
	speed = 0
	T = 0.0
	H = 0.0
	direction = Vector2()
	max_H = 0.0
	limit_H = 0.0
	anim_nxt = "idle"
	status = INGAME

func attach_player(p):
	detach_player()
	if player==null:
		var actors_bc = game.m.get_node("actors/ball_container")
		var ball = actors_bc.get_child(0)
		actors_bc.remove_child(ball)
		p.get_node("ball_container").add_child(ball)
		p.has_ball = true
		self.position = Vector2(0,0)
		self.player = p
		last_player_id = p.id
		last_team_id = p.team
		game.m.camera_to_player(p.team, p.id)
		H = 0.0
		status = INGAME
	#status = ATTACHED_TO_PLAYER

func detach_player():
	if player!=null:
		position = game.m.get_ball_position()
		player.has_ball = false
		var ball_container = player.get_node("ball_container")
		var ball = ball_container.get_child(0)
		ball_container.remove_child(ball)
		game.m.get_node("actors/ball_container").add_child(ball)
		player = null
		game.m.camera_to_ball()
		status = INGAME

func get_player():
	return player
	
func reset(pos, ingame):
	player = null
	last_player_id = -1
	last_team_id = -1
	speed_up = 0
	speed = 0
	T = 0.0
	H = 0.0
	direction = Vector2()
	max_H = 0.0
	limit_H = 0.0
	anim_nxt = "idle"
	if ingame:
		status = INGAME
	else:
		status = OUTOFGAME 
	
	
func do_move2(delta):
	T+=delta
	if speed_up>0.2:
		H = -0.5*(G*T*T)+speed_up*T
		$anim.playback_speed = 1.0
	else:
		$anim.playback_speed = 2.0
	if limit_H!=0.0 and H>limit_H:
		H = limit_H
	var input_velocity = direction.normalized() * speed
	# If there's input, accelerate to the input velocity
	if input_velocity.length() > 0:
		velocity = velocity.linear_interpolate(input_velocity, acceleration)
	else:
		# If there's no input, slow down to (0, 0)
		velocity = velocity.linear_interpolate(Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)

func do_move(delta):
	T+=delta
	if speed_up>0.2:
		H = -0.5*(G*T*T)+speed_up*T
	if limit_H!=0.0 and H>limit_H:
		H = limit_H
	var vel = direction*speed
	move_and_slide(vel.linear_interpolate(vel, 0.5))
		
	#move_and_slide(direction*speed)
	
func kick(direction, speed, speed_up):
	max_H = 0.0
	limit_H = 0.0
	T = 0.0
	H = 0.0
	self.speed = speed
	self.speed_up = speed_up
	self.direction = direction
	startpos = global_position
	velocity = Vector2.ZERO
	first_bounce = true
	
func reflect(normal, bounce):
	var ref = false
	if (normal.y>0 and direction.y<0) or (normal.y<0 and direction.y>0):
		direction.y *= -1
		speed *= bounce
	elif (normal.x>0 and direction.x<0) or (normal.x<0 and direction.x>0):
		direction.x *= -1
		speed *= bounce
		
func get_position():
	return global_position
	
func is_ingame():
	if status==INGAME:
		return true
	return false
	
func _anim():
	if anim_nxt != anim_cur:
		anim_cur = anim_nxt
		$anim.play( anim_cur )
		
func _do_interact():
#	if status!=OUTOFGAME:
	if status==INGAME or status==INGOAL or status==ISOUT:
		# verifica le possibili collisioni verso i giocatori/bordi campo/porte
		var areas = $hitbox.get_overlapping_areas()
		for a in areas:
			var obj = a.get_parent()
			if obj.has_method("interact_with_ball"):
				if obj!=player:
					if obj.interact_with_ball(self, a):
						break
					
					
func _check_out():
	if status==INGAME:
		var ballpos = global_position
		if round(ballpos.x)<-112 or round(ballpos.x)>112 or round(ballpos.y)<-145 or round(ballpos.y)>145:
			print("OUT")
			status = ISOUT

func _dump_travelled_distance():
	if first_bounce:
		first_bounce = false
		var d = global_position.distance_to(startpos)
		print("travelled distance = " + str(d))

func _check_height(delta):
	if H>2.7:
		$ball.z_index = 2.0
	else:
		$ball.z_index = 0.0
	if H<0.0:
		_dump_travelled_distance()
		# bounce
		#print("BOUNCE max_H = " + str(max_H))
		max_H = 0.0
		T = 0.0
		H = 0.0
		speed *= 0.8
		speed_up /= 2
	if H<0.1:
		H = 0.0
		speed -= T_FRICTION*delta
		$ball.position.y = 0
	else:
		var p = int(H/0.3)
		var s = int(H/4.0)+1
		#s = 1.0
		$ball.position.y = -1*p
		$ball.scale.x = s
		$ball.scale.y = s
		speed -= A_FRICTION*delta 
	

func _physics_process(delta):
	if game.paused:
		return
		
	if player!=null:
		anim_nxt = "move"
		$anim.playback_speed = 1.0
	elif speed<=0:
		_dump_travelled_distance()
		speed = 0
		anim_nxt = "idle"
		$ball.position.y = 0
		$ball.scale.x = 1.0
		$ball.scale.y = 1.0
	else:
		do_move2(delta)
		
	_do_interact()
	_check_height(delta)
	_check_out()
	_anim()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if H>max_H:
		max_H = H
