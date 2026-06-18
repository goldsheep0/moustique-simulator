class_name Proboscis
extends Node2D


@export var ground: Ground
@export var moustique: Moustique
@export var blood_collector: BloodCollector

var pumping: bool = false
var pumping_position: Vector2
var velocity: Vector2
var previous_pos: Vector2 = Vector2.ZERO

var resistance: float = 0
var objective_seconds: float = 5
var timer: float

signal proboscis_out

@onready var particles: GPUParticles2D = $Particles/ParentParticles


func _ready() -> void:
	ground.skin_ruptured.connect(_on_skin_ruptured)
	moustique.ground_touched.connect(_on_moustique_ground_touched)
	particles.emitting = false


func _process(delta: float) -> void:
	
	var counter_force = Vector2.ZERO
	var ground_to_proboscis = global_position - ground.global_position
	if ground_to_proboscis.length() < ground.radius:
		var normal = ground_to_proboscis.normalized()
		counter_force = normal * (ground.radius - ground_to_proboscis.length()) * (1. + 1.2*resistance)
		
	var target = get_global_mouse_position() + counter_force
	
	if pumping:
		# On ne peut bouger que verticalement
		target = get_global_mouse_position() - ground.position
		var normal = (pumping_position - ground.global_position).normalized()
		target = target.dot(normal) * normal + ground.position
		
		timer += delta
		$Trompe.material.set("shader_parameter/process", timer / objective_seconds)
		
		if timer > objective_seconds:
			blood_collector.add_blood(objective_seconds / 10)
			timer = 0
			$Slurp.play()
		
		if (global_position.distance_to(ground.global_position) > ground.radius): # On est sorti
			pumping = false
			particles.emitting = false
			proboscis_out.emit()
			$Trompe.material.set("shader_parameter/process", 0)
	
	if moustique.on_ground:
		global_position = lerp(global_position, target, .1)
		global_rotation = (Vector2.UP.angle_to(ground_to_proboscis))
		modulate.a = lerpf(modulate.a, 1, 0.2)
	else:
		if global_position.distance_to(ground.global_position) < ground.radius + 50:
			var normal = (global_position - ground.global_position).normalized()
			target = global_position + normal * 240
			global_position = lerp(global_position, target, .1)
		modulate.a = lerpf(modulate.a, 0, 0.2)
	
	velocity = global_position - previous_pos
	previous_pos = global_position


func _on_skin_ruptured() -> void:
	timer = 0
	pumping = true
	pumping_position = global_position
	particles.emitting = true


func _on_moustique_ground_touched() -> void:
	var normal = (get_global_mouse_position() - ground.global_position).normalized()
	global_position = ground.global_position + normal * (ground.radius + 240)
