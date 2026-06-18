class_name Arm
extends Node2D


@onready var bone_length = $Bone.get_child(0).shape.b.x

const POINT_SCENE = preload("res://scenes/point.tscn")


func _ready() -> void:
	create_points(5)
	var points = $Points.get_children()
	for i in range(len(points)):
		var point: RigidBody2D = points[i]
		create_bone_joint(point)
		if i+1 < len(points):
			create_other_node_joint(point, points[i + 1])


func create_points(spacing: int) -> void:
	for i in range(int(bone_length / spacing)):
		var new_point = POINT_SCENE.instantiate()
		$Points.add_child(new_point)
		new_point.position = Vector2(i * spacing, -f(i * spacing) * 64)


func f(x: float) -> float: # Retourne une courbe entre 0 et 1
	return (-pow((x / bone_length), 2) + (x / bone_length)) * 4


func create_bone_joint(point: RigidBody2D) -> void:
	var bone_joint = DampedSpringJoint2D.new()
	bone_joint.node_a = point.get_path()
	bone_joint.node_b = $Bone.get_path()
	bone_joint.length = point.global_position.distance_to($Bone.global_position)
	bone_joint.stiffness = 50
	point.add_child(bone_joint)
	bone_joint.global_position = point.global_position


func create_other_node_joint(point: RigidBody2D, other_point: RigidBody2D) -> void:
	var new_joint = DampedSpringJoint2D.new()
	new_joint.node_a = point.get_path()
	new_joint.node_b = other_point.get_path()
	new_joint.length = point.global_position.distance_to(other_point.global_position)
	new_joint.rotation_degrees = -90
	new_joint.stiffness = 100
	point.add_child(new_joint)
	new_joint.global_position = point.global_position


func create_line() -> void:
	$Line2D.clear_points()
	var line_points: PackedVector2Array = []
	for point in $Points.get_children():
		line_points.append(point.global_position - $Line2D.global_position)
	$Line2D.points = line_points


func _process(delta: float) -> void:
	create_line()
