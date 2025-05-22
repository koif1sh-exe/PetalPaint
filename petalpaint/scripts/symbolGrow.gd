extends Area2D

@onready var sprite = $Sprite2D

func _on_mouse_entered() -> void:
	sprite.scale *= 1.25


func _on_mouse_exited() -> void:
	sprite.scale *= .75
