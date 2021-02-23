extends KinematicBody2D

const DIR_NONE = 0
const DIR_UP = 1
const DIR_UPRIGHT = 2
const DIR_RIGHT = 3
const DIR_DOWNRIGHT = 4
const DIR_DOWN = 5
const DIR_DOWNLEFT = 6
const DIR_LEFT = 7
const DIR_UPLEFT = 8

var anim_cur = ""
var anim_nxt = ""
var fsm = null

export (int) var speed = 32
export (bool) var has_ball = false setget _set_has_ball, _get_has_ball
export (bool) var controlled = false setget _set_controlled, _get_controlled
export (int) var team = 0
export (int) var skin = 0 setget _set_skin
export (int) var id = 0

var skin_redA = preload("res://assets/Player_16x16_Sheet_Red_A.png")
var skin_redB = preload("res://assets/Player_16x16_Sheet_Red_B.png")
var skin_redC = preload("res://assets/Player_16x16_Sheet_Red_C.png")
var skin_redD = preload("res://assets/Player_16x16_Sheet_Red_D.png")

var skin_blueA = preload("res://assets/Player_16x16_Sheet_Blue_A.png")
var skin_blueB = preload("res://assets/Player_16x16_Sheet_Blue_B.png")
var skin_blueC = preload("res://assets/Player_16x16_Sheet_Blue_C.png")
var skin_blueD = preload("res://assets/Player_16x16_Sheet_Blue_D.png")

#var is_cutscene = false

var velocity = Vector2()
var lastdir = Vector2()
var direction = DIR_NONE
var actionA = false
var actionA_timing = 0
var actionB = false

var move_timing = 0

var nocatchball = false

var target = null

const pass_type1 = [[40,0,15],[50,0,24],[60,0,35],[70,0,48],[80,0,63],[90,0,80],[100,0,99]]
const pass_type2 = [[40,6,33],[50,6,44],[60,6,54],[70,6,65],[80,6,76],[90,6,87],[100,6,98]]

func _set_has_ball(v):
	has_ball = v
	#$ball.visible = v
	
func _get_has_ball():
	return has_ball
	
func _set_controlled(v):
	controlled = v
	$cursor.visible = controlled
	#$camera_target/camera.current = controlled
	
func _get_controlled():
	return controlled

func _set_skin(v):
	skin = v
	if team==0:
		match skin:
			0:
				$player.set_texture(skin_redA)
			1:
				$player.set_texture(skin_redB)
			2:
				$player.set_texture(skin_redC)
			3:
				$player.set_texture(skin_redD)
	else:
		match skin:
			0:
				$player.set_texture(skin_blueA)
			1:
				$player.set_texture(skin_blueB)
			2:
				$player.set_texture(skin_blueC)
			3:
				$player.set_texture(skin_blueD)
		
func _setup_player():
	#$ball.visible = has_ball
	$cursor.visible = controlled
	#$camera_target/camera.current = controlled
	
func _ready():
	move_timing = 0
	self.has_ball = false
	nocatchball = false
	anim_nxt = "idle"
	fsm = preload("res://scripts/fsm.gd").new( self, $states, $states/idle, false )
	_setup_player()
	
var directions = [DIR_RIGHT, DIR_DOWNRIGHT, DIR_DOWN, DIR_DOWNLEFT, DIR_LEFT, DIR_UPLEFT, DIR_UP, DIR_UPRIGHT]

func _vector2direction(v):
	if v==Vector2.ZERO:
		return DIR_NONE
	var angle = v.angle()
	if angle<0:
		angle += 2*PI
	var index = round(angle/PI*4)
	if index>=8:
		index = 0
	#print(index)
	#return DIR_NONE
	return directions[index]

var drag_enabled = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			drag_enabled = event.pressed

func get_joy():
	actionA = false
	actionB = false
	direction = DIR_NONE
	velocity = Vector2()
	velocity.x = Input.get_action_strength("btn_right") - Input.get_action_strength("btn_left")
	velocity.y = Input.get_action_strength("btn_down") - Input.get_action_strength("btn_up")
	
	if Input.is_action_just_released('btn_actionA'):
		actionA = true
	if Input.is_action_just_pressed('btn_actionA'):
		actionA_timing = 0
	if Input.is_action_just_released('btn_actionB'):
		actionB = true
	
	# If input is digital, normalize it for diagonal movement
	if abs(velocity.x) == 1 and abs(velocity.y) == 1:
		velocity = velocity.normalized()
		
	if drag_enabled:
		var new_position = get_global_mouse_position()
		velocity = new_position - position
		velocity = velocity.normalized()
		
	direction = _vector2direction(velocity)
	if velocity!=Vector2.ZERO:
		lastdir = velocity.normalized()

func _update_actionA_timing(delta):
	actionA_timing += delta
	if actionA_timing>1.0:
		actionA_timing = 1.0

func get_input():
	actionA = false
	actionB = false
	direction = DIR_NONE
	velocity = Vector2()
	
	if Input.is_action_pressed('btn_right'):
		velocity.x += 1
	if Input.is_action_pressed('btn_left'):
		velocity.x -= 1
	if Input.is_action_pressed('btn_down'):
		velocity.y += 1
	if Input.is_action_pressed('btn_up'):
		velocity.y -= 1
		
	if Input.is_action_just_released('btn_actionA'):
		actionA = true
	if Input.is_action_just_pressed('btn_actionA'):
		actionA_timing = 0
	if Input.is_action_just_released('btn_actionB'):
		actionB = true
	
	if velocity.y>0:
		direction = DIR_DOWN
		if velocity.x>0:
			direction = DIR_DOWNRIGHT
		elif velocity.x<0:
			direction = DIR_DOWNLEFT
	elif velocity.y<0:
		direction = DIR_UP
		if velocity.x>0:
			direction = DIR_UPRIGHT
		elif velocity.x<0:
			direction = DIR_UPLEFT
	elif velocity.x>0:
		direction = DIR_RIGHT
	elif velocity.x<0:
		direction = DIR_LEFT
	
func set_direction():
	direction = _vector2direction(velocity)
	
func move_to_target():
	var to_target = false
	if target!=null:
		velocity = (target-position).normalized()*speed
		if (target-position).length()>1:
			velocity = move_and_slide(velocity)
			direction = _vector2direction(velocity)
		else:
			position = target
			to_target = true
	return to_target
		
func do_shoot():
	do_kick(lastdir, 100, 6)

func do_kick(kick_dir, kick_speed, kick_speedup):
	var ball = game.m.get_ball()
	ball.detach_player()
	ball.kick(kick_dir, kick_speed, kick_speedup)
	nocatchball = true
	self.has_ball = false
	$nocatchball_timer.start()
		
# Shortest distance (angular) between two angles.
# It will be in range [0, 180].
func _angle_difference(alpha,  beta):
	var phi = int(abs(beta-alpha)) % 360       # This is either the distance or 360 - distance
	if phi>180:
		return 360-phi
	return phi
    
func do_kickoff():
	var pass_player = null
	var min_d = 1000
	for i in range(1, game.m.TEAM_PLAYERS):
		var p = game.m.get_player(self.team, i)
		if p.id!=self.id:
			var dist = position.distance_to(p.position)
			if dist<min_d:
				min_d = dist
				pass_player = p
	if pass_player!=null:
		pass_player.fsm.state_nxt = pass_player.fsm.STATES.receivepassage
		var aa = pass_player.position.angle_to_point(game.m.get_ball_position())
		var kick_dir = Vector2(cos(aa), sin(aa))
		do_kick(kick_dir, 50, 1)
		#fsm.state_nxt = fsm.STATES.ingame
	
func do_pass():
	if lastdir!=Vector2.ZERO:
		var a = rad2deg(lastdir.angle())
		var max_d = 100.0
		var min_d = 16.0
		var pass_player = null
		for i in range(1, game.m.TEAM_PLAYERS):
			var p = game.m.get_player(team, i)
			if p.id!=self.id:
				var b = rad2deg(p.position.angle_to_point(position))
				var diff = _angle_difference(a, b)
				if diff<22:
					var d = position.distance_to(p.position)
					if d<max_d and d>min_d:
						max_d = d
						pass_player = p
		if pass_player!=null:
			print("pass_player = " + str(pass_player.id))
			#in base a d seleziona il tipo di passaggio
			var pass_type = pass_type1
			if randi()%2==0:
				pass_type = pass_type2
			var dd = 1000
			var kick_speed = pass_type[0][0]
			var kick_speedup = pass_type[0][1]
			var kick_distance = pass_type[0][2]
			for x in pass_type:
				if abs(max_d-x[2])<dd:
					dd = max_d-x[2]
					kick_speed = x[0]
					kick_speedup = x[1]
					kick_distance = x[2]
			# setta la posizione dove avverrà il passaggio
			#var aa = game.m.get_ball_position().angle_to_point(pass_player.position)
			var aa = pass_player.position.angle_to_point(game.m.get_ball_position())
			var target_point = polar2cartesian(kick_distance, aa)
			print("target point = " + str(target_point))
			#pass_player.target = target_point
			pass_player.fsm.state_nxt = pass_player.fsm.STATES.receivepassage
			#game.m.set_controlled_player(pass_player.team, pass_player.id)
			var kick_dir = Vector2(cos(aa), sin(aa))
			do_kick(kick_dir, kick_speed, kick_speedup)
		else:
			do_kick(lastdir, 70, 6)
			
		#verifica per tutti i giocatori che stanno nell'angolo di azione
		#polar2cartesian(radius, angle)
	

func _angle_to_direction(angle):
	var a = rad2deg(angle)
	var d = DIR_NONE
	if a<22.5 and a>=-22.5:
		d = DIR_UP
	elif a<-22.5 and a>=-67.5:
		d = DIR_UPRIGHT
	elif a<-67.5 and a>=-112.5:
		d = DIR_RIGHT
	elif a<-112.5 and a>=-157.5:
		d = DIR_DOWNRIGHT
	elif a>=22.5 and a<67.5:
		d = DIR_UPLEFT
	elif a>=67.5 and a<112.5:
		d = DIR_LEFT
	elif a>=112.5 and a<157.5:
		d = DIR_DOWNLEFT
	else:
		d = DIR_DOWN
	return d
	
func direction_from_ball():
	var v = game.m.get_ball_position()-position
	direction = _angle_to_direction(v.angle_to(Vector2(0,-1)))
	
func anim_direction():
	match direction:
		DIR_UP:
			anim_nxt = "run_up"
		DIR_UPRIGHT:
			anim_nxt = "run_upright"
		DIR_RIGHT:
			anim_nxt = "run_right"
		DIR_DOWNRIGHT:
			anim_nxt = "run_downright"
		DIR_DOWN:
			anim_nxt = "run_down"
		DIR_DOWNLEFT:
			anim_nxt = "run_downleft"
		DIR_LEFT:
			anim_nxt = "run_left"
		DIR_UPLEFT:
			anim_nxt = "run_upleft"

func _anim():
	if anim_nxt != anim_cur:
		anim_cur = anim_nxt
		$anim.play( anim_cur )
	
func _physics_process( delta ):
	if game.paused:
		return
	
	#var global_ball = game.m.get_ball()
	#var ball_player = global_ball.player
	#var player_ball = null
	#if $ball_container.get_child_count()>0:
	#	player_ball = $ball_container.get_child(0)
	
	# update states machine
	fsm.run_machine(delta)
	_anim()
	_update_actionA_timing(delta)
	_update_move_timing(delta)
	if velocity!=Vector2.ZERO:
		lastdir = velocity.normalized()
	#_check_limits()
	#_check_hit()
	#_shadow()
	#_shield_flashing(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func move_timing_set(t):
	move_timing = t

func _update_move_timing(delta):
	if move_timing>0:
		move_timing -= delta
	else:
		move_timing = 0

func move_timing_elapsed():
	if move_timing<=0:
		return true
	return false 

# warning-ignore:unused_argument
func interact_with_ball(ball, area):
	#if controlled and not has_ball and not nocatchball:
	if ball.player==null and not has_ball and not nocatchball and ball.status==ball.INGAME and team==game.m.TEAM_A:
		if ball.H<1.5:
			#todo!!! verificare se la speed è alta, in tal caso reflect sul giocatore
			ball.attach_player(self)
			game.m.set_controlled_player(team, id)
			#self.controlled = true
			return true
	return false
			
func _on_nocatchball_timer_timeout():
	nocatchball = false
	
