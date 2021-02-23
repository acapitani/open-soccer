extends Camera2D

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

const SMOOTHING_DURATION = 0.02

var target = null
# Current position of the camera
var current_position = Vector2()

# Position the camera is moving towards
var destination_position = Vector2()

func _ready():
	game.camera = self

#func _process(delta):
	#global_position = global_position.round()

#onready var ball = get_node("../../player")

func _process(delta):
	if target!=null:
		set_position(target.position)
		#position = target.get_ref().position
		force_update_scroll()
		
		#destination_position = target.get_ref().position
		#current_position += Vector2(destination_position.x - current_position.x, destination_position.y - current_position.y) / SMOOTHING_DURATION * delta
		#position = current_position
		
		#force_update_scroll()
	pass
	#if ball!=null:
	#	pass
		#position = ball.position.round()
		#set_pos(position)
		#force_update_scroll()
	
func _physics_process( delta ):	
	return
	# Only shake when there's shake time remaining.
	if _timer == 0: return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		offset -= _last_offset - new_offset
		#set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		offset -= _last_offset
		#set_offset(get_offset() - _last_offset)
		is_shaking = false

var is_shaking = false
# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
	if is_shaking: return
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	offset -= _last_offset
	#set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)