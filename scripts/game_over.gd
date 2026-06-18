class_name GameOver
extends Control


@onready var retry_button: Button = $RetryButton


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	retry_button.visible = false
	visible = true
	if not Global.first_play:
		$Slap.play()
	else:
		Global.first_play = false
	get_tree().create_timer(1.5).timeout.connect(_enable_button)


func _enable_button() -> void:
	var tween = get_tree().create_tween()
	retry_button.modulate.a = 0
	retry_button.visible = true
	tween.tween_property(retry_button, "modulate", Color(1,1,1,1), 1)


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
