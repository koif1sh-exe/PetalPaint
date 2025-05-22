extends SubViewportContainer

# handles the saving

func _on_button_pressed() -> void:
	await RenderingServer.frame_post_draw
	$CanvasViewport.get_texture().get_image().save_png("./testCanvas.png")
