extends Area3D

@export var scale_multiplier: float = 2.5

@onready var sprite_3d: Sprite3D = $Sprite3D

var initial_scale: Vector3
var target_large_scale: Vector3
var is_scaled_up: bool = false

func _ready() -> void:
	initial_scale = sprite_3d.scale
	target_large_scale = initial_scale * scale_multiplier
	
	# Set the initial opacity to 50% (0.5 alpha) when the game starts
	sprite_3d.modulate.a = 0.5

func _input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_scale_and_opacity()

func toggle_scale_and_opacity() -> void:
	is_scaled_up = !is_scaled_up
	
	# Determine target scale and target alpha (1.0 for full, 0.5 for half)
	var target_scale: Vector3 = target_large_scale if is_scaled_up else initial_scale
	var target_alpha: float = 1.0 if is_scaled_up else 0.5
	
	# Create a parallel tween so both animations happen at the exact same time
	var tween = create_tween().set_parallel(true)
	
	# Animate the scale
	tween.tween_property(sprite_3d, "scale", target_scale, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Animate the opacity property (modulate:alpha)
	tween.tween_property(sprite_3d, "modulate:a", target_alpha, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
