class_name CameraWaypoint3D
extends Marker3D
## Drop these in place of plain Marker3D nodes to mark camera positions.
## Each one can optionally override the rig's default transition time
## and pick its own easing style.

enum EaseStyle { LINEAR, EASE_IN, EASE_OUT, EASE_IN_OUT }

@export var transition_time: float = -1.0 ## -1 = use CameraRig.default_transition_time
@export var ease_style: EaseStyle = EaseStyle.EASE_IN_OUT
