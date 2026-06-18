class_name Point
extends RigidBody2D


var direction = Vector2.ZERO
var force: int = 50


func _ready() -> void:
	create_timer()


func create_timer() -> void:
	get_tree().create_timer(randf_range(1., 1.)).timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	#apply_force(direction * force)
	pass


func _on_timer_timeout() -> void:
	direction = Vector2(0, Vector2.RIGHT.rotated(randf_range(0, 2*PI)).dot(Vector2.RIGHT))
	create_timer()
