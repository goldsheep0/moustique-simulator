class_name Moustique
extends CharacterBody2D


@export var proboscis: Proboscis
@export var ground: Ground
@export var camera: Camera2D

var on_ground: bool = true
var ground_velocity: Vector2 = Vector2.ZERO

const SPEED = 300.0
const VERTICAL_SPEED = -100.0
const GRAVITY_SCALE = 400

signal ground_touched


func _ready() -> void:
	ground_touched.connect(_on_ground_touched)


func _physics_process(delta: float) -> void:

	var horizontal_direction := Input.get_axis("left", "right")
	if horizontal_direction:
		ground_velocity.x = horizontal_direction * SPEED
	else:
		ground_velocity.x = move_toward(ground_velocity.x, 0, SPEED/30)
	
	if Input.is_action_pressed("up"):
		if not $Buzz.playing and not proboscis.pumping:
			$Buzz.play()
		ground_velocity.y = clampf(ground_velocity.y + VERTICAL_SPEED, VERTICAL_SPEED, 1000)
	
	ground_velocity.y += GRAVITY_SCALE * delta
	
	if (global_position.distance_to(ground.global_position) < ground.radius):
		if not on_ground:
			ground_touched.emit()
		ground_velocity.x = 0
		if not proboscis.pumping: #Si on ne pompe pas, on peut s'en aller
			ground_velocity.y = clampf(ground_velocity.y, VERTICAL_SPEED, 0)
		else:
			ground_velocity.y = 0
	else:
		if on_ground:
			camera.dezoom_camera()
		on_ground = false
	
	var ground_to_moustique = (global_position - ground.position).normalized()
	velocity = ground_velocity.rotated(Vector2.UP.angle_to(ground_to_moustique))

	move_and_slide()
	
	animate()


func animate() -> void:
	var ground_to_moustique = (global_position - ground.position).normalized()
	global_rotation = Vector2.UP.angle_to(ground_to_moustique)
	
	if on_ground:
		modulate.a = lerpf(modulate.a, 0, .2)
		scale = Vector2.ONE * 1.5
	else:
		modulate.a = lerpf(modulate.a, 1, .2)
		scale = Vector2.ONE * 1
	
	$Buzz.volume_db = remap(ground_velocity.y, 0, VERTICAL_SPEED, -50, -20)


func _on_ground_touched() -> void:
	camera.zoom_camera()
	on_ground = true
	$Buzz.stop()
