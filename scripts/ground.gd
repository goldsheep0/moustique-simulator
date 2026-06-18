class_name Ground
extends Node2D


@export var radius = 480
@export var proboscis: Proboscis
@export var moustique: Moustique

var noise1: FastNoiseLite  = FastNoiseLite.new()
var noise2: FastNoiseLite  = FastNoiseLite.new()
var noise3: FastNoiseLite  = FastNoiseLite.new()

var noise_alerte: FastNoiseLite  = FastNoiseLite.new()
var noise_toughness: FastNoiseLite = FastNoiseLite.new()
var alert_level: float = 0
var vitesse_gain_alerte: float = 1./10 # 1 / X secondes pour atteindre le game over

var skin_animation: float = -1

var pierced: bool = false
signal skin_ruptured

@onready var line: Line2D = $Line2D


func _ready() -> void:
	noise1.frequency = .1
	noise2.frequency = 1
	noise3.frequency = 10
	noise_alerte.frequency = 50
	noise_toughness.frequency = 5
	skin_ruptured.connect(_on_skin_ruptured)
	proboscis.proboscis_out.connect(_on_proboscis_out)


func create_line(pixel_par_point: int) -> void:
	var length = 2 * PI * radius
	var nombre_points = int(length / pixel_par_point)
	var line_points = []
	
	for point_index in range(nombre_points):
		var point_angle = float(point_index) / nombre_points * 2*PI
		var point_coord = (Vector2.RIGHT * radius).rotated(point_angle)
		var height_displacement = 60 * noise1.get_noise_2d(point_angle, float(Time.get_ticks_msec())*.00001)
		height_displacement += 20 * noise2.get_noise_2d(point_angle, float(Time.get_ticks_msec())*.00003)
		height_displacement += 7 * noise3.get_noise_2d(point_angle, float(Time.get_ticks_msec())*.00005)
		height_displacement += 25 * alert_level * noise3.get_noise_2d(point_angle, float(Time.get_ticks_msec())*.00005*(pow(alert_level, 2)*1.5))
		point_coord = point_coord + point_coord.normalized() * height_displacement
		
		if skin_animation >= 0:
			point_coord += skin_animation * move_point_with_proboscis(point_coord, point_angle)
			point_coord += move_point_with_proboscis_velocity(point_coord, point_angle)
		else:
			point_coord += move_point_with_proboscis(point_coord, point_angle)
		
		line_points.append(point_coord)
		
		set_proboscis_resistance()
		
		play_wet_sound()
		
	line.points = line_points


func move_point_with_proboscis(point_coord: Vector2, point_angle: float) -> Vector2:
	var area_of_effect = 0.9996 # 0 (tout) à 1 (rien)
	var proboscis_angle = (proboscis.global_position - global_position).angle()
	var point_to_proboscis = proboscis.global_position - (point_coord + global_position)
	var dot_product_shenanigans = (Vector2.from_angle(proboscis_angle).dot(Vector2.from_angle(point_angle)) - area_of_effect) / (1-area_of_effect)
	if dot_product_shenanigans >= 0: # Si dans la zone
		if point_to_proboscis.normalized().dot(Vector2.from_angle(point_angle)) < 0: # Si on pointe vers le bas
			return Vector2.from_angle(point_angle) * (point_to_proboscis * pow(dot_product_shenanigans,10)).dot(Vector2.from_angle(point_angle))
	return Vector2.ZERO


func move_point_with_proboscis_velocity(point_coord: Vector2, point_angle: float) -> Vector2:
	var area_of_effect = 0.9996 # 0 (tout) à 1 (rien)
	var proboscis_angle = (proboscis.global_position - global_position).angle()
	var point_to_proboscis = proboscis.global_position - (point_coord + global_position)
	var dot_product_shenanigans = (Vector2.from_angle(proboscis_angle).dot(Vector2.from_angle(point_angle)) - area_of_effect) / (1-area_of_effect)
	if dot_product_shenanigans >= 0: # Si dans la zone
		if (proboscis.global_position - global_position).length() < radius-20:
			return -5 * Vector2.from_angle(point_angle) * (point_to_proboscis.normalized() * pow(dot_product_shenanigans,10)).dot(Vector2.from_angle(point_angle)) * (proboscis.global_position - global_position).normalized().dot(proboscis.velocity)
	return Vector2.ZERO


func set_proboscis_resistance() -> void:
	var proboscis_angle = (proboscis.global_position - global_position).angle()
	var resistance = noise_toughness.get_noise_1d(proboscis_angle)
	resistance = (resistance + 1) / 2
	proboscis.resistance = resistance


func play_wet_sound() -> void:
	if proboscis.global_position.distance_to(global_position) < radius-10:
		if not pierced and not $Wet.playing:
			if proboscis.velocity.length() > 0.1:
				$Wet.play()
		elif proboscis.velocity.length() < 0.1:
			$Wet.stop()
	else:
		$Wet.stop()


func _process(delta: float) -> void:
	create_line(2)
	skin_animation = lerpf(skin_animation, 0, 0.2)
	
	if global_position.distance_to(proboscis.global_position) - radius < -50 and not proboscis.pumping:
		skin_ruptured.emit()
	
	if global_position.distance_to(proboscis.global_position) - radius < 0:
		alert_level += vitesse_gain_alerte * delta
		$Underwater.volume_db = remap(alert_level, 0, 1, 0, 10)
		if alert_level >= 1:
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	else:
		alert_level = move_toward(alert_level, 0, vitesse_gain_alerte * delta * 2)
		$Underwater.volume_db = clampf(remap(global_position.distance_to(moustique.global_position), 960, 2000, 0, -50), -50, 0)


func _on_skin_ruptured() -> void:
	skin_animation = 1.0
	pierced = true
	proboscis.objective_seconds = randi_range(3, 6)
	$WetPiecring.play()
	noise_toughness.seed = noise_toughness.seed + 1


func _on_proboscis_out() -> void:
	skin_animation = -1
	pierced = false
	vitesse_gain_alerte = 1. / randf_range(5, 20)


func set_line_width(width: float) -> void:
	line.width = width
