class_name BloodVessel
extends MarginContainer


var quantite: float = 0
var color: Vector3

@onready var interieur: TextureRect = $Interieur


func _process(_delta: float) -> void:
	interieur.material.set("shader_parameter/modulate", color);


func set_level(qu: float) -> void:
	quantite = qu
	color = Vector3(1, 1, 1)
	interieur.material.set("shader_parameter/quantite", quantite);
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'color', Vector3(.8, 0, 0), .5)
