extends "res://scenes/scene.gd"

const TEAM_PLAYERS = 11
const TEAM_A = 0
const TEAM_B = 1

const GK_ID = 0

const FIRST_HALF = 0
const SECOND_HALF = 1
const FIRST_EXTRATIME = 2
const SECOND_EXTRATIME = 3
const PENALTY_KICKS = 4

var teamA = []
var teamB = []
var ball = null

var team_up = TEAM_B
var team_down = TEAM_A

var team_tacticsA = [4,3,3]
var team_tacticsB = [3,5,2]

var team_startpos_up = []
var team_startpos_down = []

var fsm = null
var idle_state_nxt = ""
var kickoff_team = TEAM_A
var match_time = FIRST_HALF
var teamA_mode = game.CPU
var teamB_mode = game.CPU

func _ready():
	teamA_mode = game.CPU
	teamB_mode = game.CPU
	if game.game_mode==game.MODE_1PVSCPU:
		teamA_mode = game.PLAYER
	elif game.game_mode==game.MODE_1PVS2P:
		teamA_mode = game.PLAYER
		teamB_mode = game.PLAYER
		
	#fsm = preload("res://scripts/fsm.gd").new( self, $states, $states/enterpitch, false )
	fsm = preload("res://scripts/fsm.gd").new(self, $states, $states/kickoff, false)
	game.m = self
	_setup_team_startpos()
	call_deferred("_setup_actors")
	
func get_pitch_position(name):
	var pp = "pitch/pitch/positions/"
	pp += name
	return self.get_node(pp).position
	
func get_team_tactics(team):
	if team==TEAM_A:
		return team_tacticsA
	return team_tacticsB

func get_team_mode(team):
	if team==TEAM_A:
		return teamA_mode
	return teamB_mode

func camera_to_player(team, id):
	$camera_target/camera.target = get_player(team, id)
	
func camera_to_ball():
	if $actors/ball_container.get_child_count()>0:
		$camera_target/camera.target = $actors/ball_container.get_child(0)
	
func _setup_actors():
	teamA.clear()
	teamA.append(null) # goalkeeper teamA
	teamA.append(weakref($actors/playerA1))
	teamA.append(weakref($actors/playerA2))
	teamA.append(weakref($actors/playerA3))
	teamA.append(weakref($actors/playerA4))
	teamA.append(weakref($actors/playerA5))
	teamA.append(weakref($actors/playerA6))
	teamA.append(weakref($actors/playerA7))
	teamA.append(weakref($actors/playerA8))
	teamA.append(weakref($actors/playerA9))
	teamA.append(weakref($actors/playerA10))
	
	teamB.clear()
	teamB.append(null) # goalkeeper teamB
	teamB.append(weakref($actors/playerB1))
	teamB.append(weakref($actors/playerB2))
	teamB.append(weakref($actors/playerB3))
	teamB.append(weakref($actors/playerB4))
	teamB.append(weakref($actors/playerB5))
	teamB.append(weakref($actors/playerB6))
	teamB.append(weakref($actors/playerB7))
	teamB.append(weakref($actors/playerB8))
	teamB.append(weakref($actors/playerB9))
	teamB.append(weakref($actors/playerB10))
	
	ball = weakref($actors/ball_container/ball)
	
	for i in range(1, TEAM_PLAYERS):
		var player = get_player(TEAM_A, i)
		player.id = i
		player.team = TEAM_A
		player.skin = randi()%4
		player = get_player(TEAM_B, i)
		player.id = i
		player.team = TEAM_B
		player.skin = randi()%4
			
	#$camera_target/camera.target = weakref($players/playerA1)
	#$camera_target/camera.target = get_player(TEAM_A, 1)
	#$actors/ball_container/ball.attach_player(get_player(TEAM_A, 1))
	
func _setup_team_startpos():
	var j
	team_startpos_up.clear()
	team_startpos_down.clear()
	
	#goalkeep pos
	team_startpos_up.append(Vector2(0, 0))
	team_startpos_down.append(Vector2(0, 0))
	
	var tac_up = get_team_tactics(team_up)
	var tac_down = get_team_tactics(team_down)
	var lines = [80, 50, 10]
	# team up
	var y = 0
	for t in tac_up:
		var d = 220/(t+1)
		var py = lines[y]*-1
		var px = -110+d
		j = 0
		#for j in range(0, t):
		while j<t:
			team_startpos_up.append(Vector2(px, py))
			px += d
			j+=1
		y += 1
	# team down
	y = 0
	for t in tac_down:
		var d = 220/(t+1)
		var py = lines[y]
		var px = -110+d
		j=0
		#for j in range(0, t):
		while j<t:
			team_startpos_down.append(Vector2(px, py))
			px += d
			j+=1
		y += 1
		
func get_sector(v):
	return int((v.y+140)/40)
	
	
func get_nearest_player(team, refpos):
	var dist = 10000.0
	var id = 1
	for i in range(1, self.TEAM_PLAYERS):
		var d = get_player(team, i).position.distance_to(refpos)
		if d<dist:
			dist = d
			id = i
	return get_player(team, id)
	
func get_controlled_player(team):
	var id = -1
	for i in range(1, self.TEAM_PLAYERS):
		if get_player(team, i).controlled:
			id = i
			break
	if id!=-1:
		return get_player(team, id)
	return null
	
func get_player_targetpos(team, id, refpos):
	var up = 1
	var y = refpos.y
	if y>140:
		y = 140
	elif y<-140:
		y = -140
	var v = Vector2()
	var tac = get_team_tactics(team)
	var mf_sector = int((y+140)/40)
	if team==TEAM_A:
		#attacking team
		if team==team_down:
			mf_sector = min(mf_sector, 4)
			mf_sector = max(mf_sector, 2)
			up = -1
		else:
			mf_sector = min(mf_sector, 4)
			mf_sector = max(mf_sector, 2)
	else:
		#defending team
		if team==team_down:
			mf_sector += 1
			mf_sector = min(mf_sector, 5)
			mf_sector = max(mf_sector, 3)
			up = -1
		else:
			mf_sector -= 1
			mf_sector = min(mf_sector, 3)
			mf_sector = max(mf_sector, 1)
			
	if id<=tac[0]:
		#defense
		v.x = -110+((220/(tac[0]+1))*id)
		v.y = -120+((mf_sector-up)*40)
	elif id<=tac[0]+tac[1]:
		#midfield
		var t=tac[0]
		v.x = -110+((220/(tac[1]+1))*(id-t))
		if (randi()%2)==0:
			mf_sector += up
		v.y = -120+(mf_sector*40)
	else:
		#attack
		var t=tac[0]+tac[1]
		v.x = -110+((220/(tac[2]+1))*(id-t))
		v.y = -120+((mf_sector+(up*2))*40)
	
	v.x += round(rand_range(-8, 8))
	v.y += round(rand_range(-12, 12))
	
	if team==TEAM_A and false:
		if team==team_up:
			v.y-=40
		else:
			v.y+=40
	
	if v.y>140:
		v.y=140
	elif v.y<-140:
		v.y=-140
	return v
	
func _get_player_targetpos(team, id, refpos):
	var up = 1
	var player = get_player(team, id)
	var tac = get_team_tactics(team)
	var v = refpos
	if team==team_up:
		up=-1
	var d=0
	if id<=tac[0]:
		#defense
		v.x = -110+((220/(tac[0]+1))*id)
		v.y += (60*up)
	elif id<=tac[0]+tac[1]:
		#midfield
		var t=tac[0]
		v.x = -110+((220/(tac[1]+1))*(id-t))
	else:
		var t=tac[0]+tac[1]
		v.x = -110+((220/(tac[2]+1))*(id-t))
		v.y -= (60*up)
		
	#adjust position y
	v.x += round(rand_range(-4, 4))
	v.y += round(rand_range(-4, 4))
	
	if v.y>130:
		v.y=130
	elif v.y<-130:
		v.y=-130
	
	return v
		
func get_player_startpos(team, id):
	if team==team_down:
		return team_startpos_down[id]
	return team_startpos_up[id]
	
func get_player(team, id):
	if team==TEAM_A:
		return teamA[id].get_ref()
	return teamB[id].get_ref()
	
func get_ball():
	return ball.get_ref()
	
func get_ball_position():
	return get_ball().global_position
	
func reset_controlled_player(team):
	for i in range(1, TEAM_PLAYERS):
		get_player(team, i).controlled = false
		
func set_controlled_player(team, id):
	reset_controlled_player(team)
	get_player(team, id).controlled = true

func fade_out():
	$fader/anim.play("fade_out")
	
func fade_in():
	$fader/anim.play("fade_in")
	
func idle_next_state():
	#$actors/ball.reset(Vector2(0,0),false)
	fsm.state_nxt = idle_state_nxt

func _physics_process(delta):
	if game.paused:
		return
	fsm.run_machine(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
