extends Control

# handles the drawing on SubViewPort

var myImage: Image
var myTexture: ImageTexture
var brushColor = Color(0, 0, 1)
var brushSize = 60
var brushOpacity: float = 1
var drawQueue: Array = [] # a 2d array that stores queue color data, brushSize, 
var lastPos = Vector2(0,0)
var isNewPosition = true;
var MAX_QUEUE_SIZE: int = 1000

var secondaryBrushColor : Color = Color(1.0, 1.0, 0) # green as an example
var mixAmount := 0.2 # ranges 0..1, you can expose this in UI
var mixedColor : Color
var isPrimary = true
var clearCanvasNextDraw = false # helps framerate
var isEraser = false
@onready var canvasViewport = find_parent("CanvasViewport")
@onready var colorRectPredict = %ColorRectPredict

func _ready() -> void:
	%ColorRectPrimary.color = brushColor
	%ColorRectSecondary.color = secondaryBrushColor
	#whiteCanvas()

func _input(event):
	# Alter so clicks also render circles
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = get_local_mouse_position()
		var queueSize = drawQueue.size()
		calculateColor()
		
		if(queueSize == 0):
			drawQueue.append(pos)
		else:
			drawLine(drawQueue[queueSize - 1], pos) # interpolates between points
			drawQueue.append(pos)	
		queue_redraw()
	else:
		pass
		drawQueue.clear()


func _process(_delta):
	if drawQueue.size() > MAX_QUEUE_SIZE:
		print("max reached")
		drawQueue = drawQueue.slice(int(MAX_QUEUE_SIZE/2.0), drawQueue.size())


func _draw() -> void:
	if clearCanvasNextDraw:
		print("drawing rect")
		draw_rect(Rect2(Vector2.ZERO, canvasViewport.size), Color.WHITE, true)
	else:
		for point in drawQueue:
			draw_circle(point, brushSize, mixedColor, true, -1.0, true) # antialiased = true!


func drawLine(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	var steps = int(distance)
	if steps == 0:
		drawQueue.append(from)
		return
	for i in range(1, steps):
		var t = float(i) / steps
		var point = from.lerp(to, t)
		drawQueue.append(point)


func calculateColor():
	#var col1 = [brushColor.r * 255, brushColor.g * 255, brushColor.b * 255]
	#var col2 = [secondaryBrushColor.r * 255, secondaryBrushColor.g * 255, secondaryBrushColor.b * 255]
	mixedColor = brushColor.lerp(secondaryBrushColor, brushOpacity)
	if(isEraser):
		print("eraser color")
		mixedColor = Color(mixedColor.r, mixedColor.g, mixedColor.b, 0.00)


func _on_color_picker_color_changed(color: Color) -> void:
	if(isPrimary):
		brushColor = color
		%ColorRectPrimary.color = brushColor
	else:
		secondaryBrushColor = color
		%ColorRectSecondary.color = secondaryBrushColor
	
	calculateColor()
	colorRectPredict.color = mixedColor


func _on_size_slider_value_changed(value: float) -> void:
	brushSize = value


func _on_opacity_slider_value_changed(value: float) -> void:
	brushOpacity = value
	calculateColor()
	colorRectPredict.color = mixedColor


func _on_clearBtn_pressed() -> void:
	whiteCanvas()


func whiteCanvas():
	clearCanvasNextDraw = true
	await get_tree().process_frame
	queue_redraw()
	await get_tree().process_frame
	clearCanvasNextDraw = false


func eraseCanvas():
	# Clears to nothing
		await get_tree().process_frame  # let _draw() happen first
		if(canvasViewport != null):
			canvasViewport.set_clear_mode(0) # CLEAR_MODE_ALWAYS = 0
			drawQueue.clear()
			await get_tree().process_frame # wait a frame for queue_redraw() cuz it only requests a redraw on the next frame
			queue_redraw()
			canvasViewport.set_clear_mode(1) # CLEAR_MODE_NEVER = 1


func _on_toggle_btn_pressed() -> void:
	if(isPrimary):
		isPrimary = false
		%ToggleBtn.text = "right"
	else:
		isPrimary = true
		%ToggleBtn.text = "left"


func _on_eraser_btn_pressed() -> void:
	if(isEraser):
		isEraser = false
		%EraserBtn.text = "brush"
		calculateColor()
	else:
		isEraser = true
		%EraserBtn.text = "eraser"
		calculateColor()
