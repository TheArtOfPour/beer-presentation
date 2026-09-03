extends Node3D
## Attach this to a Node3D that acts as the "rig" controller.
## Assign `camera` to your Camera3D, and `waypoints` to an array of
## CameraWaypoint3D (or plain Node3D/Marker3D) nodes, placed/rotated
## in the editor — one per set piece.

@export var camera: Camera3D
@export var waypoints: Array[Node3D] = []
@export var default_transition_time: float = 1.2
@export var transition_curve: Tween.TransitionType = Tween.TRANS_SINE
@export var wrap_around: bool = false ## if true, right at the last waypoint loops to the first

var current_index: int = 0
var is_transitioning: bool = false
var active_tween: Tween


func _ready() -> void:
	if waypoints.is_empty():
		push_warning("CameraRig: no waypoints assigned")
		return
	camera.global_transform = waypoints[0].global_transform


func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning or waypoints.size() < 2:
		return

	if event.is_action_pressed("ui_right"):
		_go_to(current_index + 1)
	elif event.is_action_pressed("ui_left"):
		_go_to(current_index - 1)


func _go_to(requested_index: int) -> void:
	var index := requested_index
	if wrap_around:
		index = wrapi(index, 0, waypoints.size())
	else:
		index = clampi(index, 0, waypoints.size() - 1)

	if index == current_index:
		return

	current_index = index
	_transition_to(waypoints[current_index])


func _transition_to(target: Node3D) -> void:
	var start_transform := camera.global_transform
	var end_transform := target.global_transform

	# Resolve per-waypoint overrides, falling back to rig defaults.
	var duration := default_transition_time
	var trans_type := transition_curve
	var ease_type := Tween.EASE_IN_OUT

	if target is CameraWaypoint3D:
		if target.transition_time >= 0.0:
			duration = target.transition_time

		match target.ease_style:
			CameraWaypoint3D.EaseStyle.LINEAR:
				trans_type = Tween.TRANS_LINEAR
				# ease_type is irrelevant for linear, Tween ignores it.
			CameraWaypoint3D.EaseStyle.EASE_IN:
				ease_type = Tween.EASE_IN
			CameraWaypoint3D.EaseStyle.EASE_OUT:
				ease_type = Tween.EASE_OUT
			CameraWaypoint3D.EaseStyle.EASE_IN_OUT:
				ease_type = Tween.EASE_IN_OUT

	is_transitioning = true

	if active_tween:
		active_tween.kill()

	active_tween = create_tween()
	active_tween.set_trans(trans_type)
	active_tween.set_ease(ease_type)
	active_tween.tween_method(
		func(t: float): camera.global_transform = start_transform.interpolate_with(end_transform, t),
		0.0, 1.0, duration
	)
	active_tween.finished.connect(func(): is_transitioning = false)
