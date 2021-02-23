extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact_with_ball(ball, area):
	var bounce = 0.6
	var ok = true
	if area==$border_up:
		ball.reflect(Vector2(0,1), bounce)
	elif area==$border_down:
		ball.reflect(Vector2(0,-1), bounce)
	elif area==$border_right:
		ball.reflect(Vector2(-1,0), bounce)
	elif area==$border_left:
		ball.reflect(Vector2(1,0), bounce)
	else:
		ok = false
	return ok
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
