extends "res://scripts/state.gd"

var kickoff_player = null

func initialize(scene):
	var player
	var ball = scene.get_ball()
	
	for i in range(1, scene.TEAM_PLAYERS):
		#team down
		player = scene.get_player(scene.team_down, i) 
		if player!=null:
			player.fsm.state_nxt = player.fsm.STATES.idle
			player.position = scene.get_player_startpos(player.team, player.id)
			if player.position.distance_to(ball.position)<30:
				player.position.y = 30
		#team up
		player = scene.get_player(scene.team_up, i) 
		if player!=null:
			player.fsm.state_nxt = player.fsm.STATES.idle
			player.position = scene.get_player_startpos(player.team, player.id)
			if player.position.distance_to(ball.position)<30:
				player.position.y = -30
			
		# posiziona il player alla battuta
		player = scene.get_player(scene.kickoff_team, 10)
		player.position = Vector2(4,-3)
		scene.get_ball().attach_player(player)
		player.fsm.state_nxt = player.fsm.STATES.kickoff
		kickoff_player = player
			
		# posiziona il compagno alla ricezione
		player = scene.get_player(scene.kickoff_team, 9)
		player.position = Vector2(-10, -3)
		

func terminate(scene):
	pass
	
func run(scene, delta):
	var ball_player = scene.get_ball().get_player()
	if ball_player!=null and ball_player!=kickoff_player:
		scene.fsm.state_nxt = scene.fsm.STATES.ingame
	