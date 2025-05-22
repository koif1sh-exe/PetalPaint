extends Button

@onready var iconTexture = $TextureRect

func _ready() -> void:
	iconTexture.hide()
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	iconTexture.show()

func _on_mouse_exited() -> void:
	iconTexture.hide()
