class_name BloodCollector
extends Node2D


@export var ui: Control

var blood_collected = 0
var current_vessel: BloodVessel

const BLOOD_SCENE = preload("res://scenes/blood_vessel.tscn")


func _ready() -> void:
	add_vessel(0)


func add_blood(quantite: float) -> void:
	if current_vessel.quantite + quantite > 1:
		current_vessel.set_level(1)
		add_vessel(quantite)
	else:
		current_vessel.set_level(current_vessel.quantite + quantite)


func add_vessel(quantite: float) -> void:
	var new_vessel = BLOOD_SCENE.instantiate()
	ui.add_child(new_vessel)
	new_vessel.call_deferred('set_level', quantite)
	current_vessel = new_vessel
