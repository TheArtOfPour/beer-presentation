extends Node

var swipe_start_position: Vector2 = Vector2.ZERO
var is_swiping: bool = false
@export var min_swipe_distance: float = 50.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			swipe_start_position = event.position
			is_swiping = true
		elif is_swiping:
			is_swiping = false
			var swipe_vector = event.position - swipe_start_position
			if swipe_vector.length() >= min_swipe_distance:
				detect_swipe_direction(swipe_vector)

func detect_swipe_direction(vector: Vector2) -> void:
	if abs(vector.x) > abs(vector.y):
		var action_name = "ui_left" if vector.x > 0 else "ui_right"
		
		# 1. Create a real InputEventAction object
		var ev = InputEventAction.new()
		ev.action = action_name
		ev.pressed = true # Simulate "pressed"
		
		# 2. Feed it into Godot's input handling system
		Input.parse_input_event(ev)
		print("Parsed input event for: ", action_name)
