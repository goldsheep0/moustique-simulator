extends Camera2D


@export var ground: Ground

var target_zoom: Vector2


func _ready() -> void:
	dezoom_camera()


func _process(_delta: float) -> void:
	zoom = lerp(zoom, target_zoom, 0.1)


func zoom_camera() -> void:
	target_zoom = Vector2.ONE
	ground.set_line_width(1)
	

func dezoom_camera() -> void:
	target_zoom = Vector2.ONE * 0.5
	ground.set_line_width(2)
