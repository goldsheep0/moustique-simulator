class_name Player
extends RigidBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -200.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		apply_force(Vector2(direction, -1) * SPEED)
