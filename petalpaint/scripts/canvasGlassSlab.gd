extends TextureRect

enum PHASE {SELECT, MIX, SPOON, HONEY, MULLER, KNIFE, ADDPAINT, NONE}

var image : Image
var brushColor : Color = Color(0, 0, 0, 0)
var brushSize : int = 40 # good size for glass muller
var is_erasing = false
var last_pos : Vector2 = Vector2(-100,-100)
var isErasing = false
var isDrawing = true
var isNothing = false
var mouseDown = false
var ratio: float
@onready var paletteKnife = %PaletteKnife
@onready var paletteKnifeCollider = paletteKnife.get_node("CollisionShape2D")
@onready var paintTableGUI = find_parent("PaintTableGUI")


func _ready():
	image = Image.create_empty(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	texture = ImageTexture.create_from_image(image) # create a texture from the image


func _input(event):
	if(isNothing):
		return
	
	if event is InputEventMouseMotion and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if(mouseDown):
			last_pos = Vector2(-100,-100)
			updateFilledRatio()
			mouseDown = false
		
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouseDown = true
		if(isErasing):
			print("erasing")
			var pos = paletteKnifeCollider.global_transform.origin - position - get_parent().global_transform.origin
			eraseLine(last_pos, pos)
			last_pos = pos
		elif(isDrawing):
			print("drawing")
			var pos = event.position - position - get_parent().position
			drawLine(last_pos, pos)
			last_pos = pos


func setColor(color: Color):
	brushColor = color


func setIsErasing(): # sets to true
	isErasing = true
	isDrawing = false
	isNothing = false


func setIsDrawing(): # sets to true
	isDrawing = true
	isErasing = false
	isNothing = false


func setIsNothing(): # sets to true
	isNothing = true
	isDrawing = false
	isErasing = false


func fillCanvas(color: Color):
	image.fill(color)
	texture.update(image) # ALWAYS update your texture image so the player can see it!!


func clearCanvas():
	image.fill(Color(0,0,0,0))
	texture.update(image)


# https://forum.godotengine.org/t/how-to-get-average-colour-of-an-image/94811/3
func updateFilledRatio():
	#var tempColor = Vector3.ZERO
	var texture_size = texture.get_size()
	var counter = 0
	
	for y in range(0, texture_size.y):
		for x in range(0, texture_size.x):
			var pixel = image.get_pixel(x, y)
			if(pixel.a > 0):
				counter += 1
	print(counter / (texture_size.x * texture_size.y))
	ratio = float(counter) / (texture_size.x * texture_size.y)
	
	if(ratio > .98):
		paintTableGUI.enableKnife()
		fillCanvas(brushColor)
		setIsErasing()
	if(ratio < .02):
		paintTableGUI.addPaint()
		setIsNothing()
		clearCanvas() 


func drawAt(pos: Vector2):
	for x in range(-brushSize, brushSize):
		for y in range(-brushSize, brushSize):
			var offset = Vector2(x, y)
			if offset.length() <= brushSize: # only draw inside circle radius
				var px = int(pos.x) + x
				var py = int(pos.y) + y
				if px >= 0 and py >= 0 and px < image.get_width() and py < image.get_height():
					image.set_pixel(px, py, brushColor)
	texture.update(image)


func drawLine(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	var steps = int(distance / 20)

	if steps == 0 || last_pos == Vector2(-100,-100):
		drawAt(from)
		return

	for i in range(steps):
		var t = float(i) / steps
		var point = from.lerp(to, t)
		drawAt(point)


func eraseAt(pos: Vector2):
	for x in range(-10, 80):
		for y in range(0, 4):
			var px = int(pos.x) + x
			var py = int(pos.y) + y
			if px >= 0 and py >= 0 and px < image.get_width() and py < image.get_height():
				image.set_pixel(px, py, Color(0, 0, 0, 0))
	texture.update(image)


func eraseLine(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	var steps = int(distance)
	
	if steps == 0 || last_pos == Vector2(-100,-100):
		eraseAt(to)
		return

	for i in range(steps):
		var t = float(i) / steps
		var point = from.lerp(to, t)
		eraseAt(point)
