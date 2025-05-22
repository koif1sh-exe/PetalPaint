extends TextureRect

# Needs a lot of work, rn the opacity isnt consistent cuz well yknow it is called too many time
# BROKEN SCRIPT

var myImage: Image
var myTexture: ImageTexture
var brushColor = Color(1, 0, 0, .5) # red
var brushSize = 40
var brushOpacity: float = 1
var last_pos = Vector2(-1, -1)  # Store the previous mouse position
var is_drawing = false
var drawQueue: Array = []

func _ready():
	var width = 512
	var height = 512
	
	myImage = Image.create(width, height, false, Image.FORMAT_RGBA8)
	myImage.fill(Color(1, 1, 1, 1)) # white background

	myTexture = ImageTexture.create_from_image(myImage)
	self.texture = myTexture

func _process(_delta):
	is_drawing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if drawQueue.size() < 2:
		return
		
	for i in range(drawQueue.size() - 1):
		var from = drawQueue[i]
		var to = drawQueue[i + 1]
		#drawLine(from, to)
		drawAt(from)

	myTexture.update(myImage)
	
	if not is_drawing:
		
		drawQueue.clear()
	else:
		# Keep the last point to continue the stroke next frame BUG HERE??
		drawQueue = [drawQueue[-1]]

func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = get_local_mouse_position()
		if(!isInImageBounds(int(pos.x),int(pos.y))):
			return
		drawQueue.append(pos)
		queue_redraw()

func _draw() -> void:
	for point in drawQueue:
		draw_circle(point, brushSize, brushColor)

func drawAt(pos: Vector2):
	var x = int(pos.x)
	var y = int(pos.y)
	
	if(!isInImageBounds(x,y)):
		return

	var src = brushColor
	var dst = myImage.get_pixel(x, y)  # background color

	# Blend src over dst
	var out_r = src.r * src.a + dst.r * (1.0 - src.a)
	var out_g = src.g * src.a + dst.g * (1.0 - src.a)
	var out_b = src.b * src.a + dst.b * (1.0 - src.a)
	var out_a = src.a + dst.a * (1.0 - src.a)  # Optional: pre-multiplied alpha

	var blended = Color(out_r, out_g, out_b, out_a)
	
	var half_size = int(brushSize / 2.0)
	
	# Loop through all pixels within the brush bounds
	for dx in range(-half_size, half_size + 1):  # Include the edge pixel
		for dy in range(-half_size, half_size + 1):
			if Vector2(dx, dy).length() <= half_size:  # Inside a circle
				var px = clamp(x + dx, 0, myImage.get_width() - 1)
				var py = clamp(y + dy, 0, myImage.get_height() - 1)
				myImage.set_pixel(px, py, blended)
#
#
func drawLine(from: Vector2, to: Vector2):
	var distance = from.distance_to(to)
	var steps = int(distance)

	if steps == 0:
		drawAt(from)
		return

	for i in range(steps):
		var t = float(i) / steps
		var point = from.lerp(to, t)
		drawAt(point)


func isInImageBounds(x: int, y: int):
	if x < 0 or y < 0 or x >= myImage.get_width() or y >= myImage.get_height(): # check for bounds
		return false
	return true

func _on_color_picker_color_changed(color: Color) -> void:
	brushColor = color


func _on_size_slider_value_changed(value: float) -> void:
	brushSize = value


func _on_opacity_slider_value_changed(value: float) -> void:
	brushOpacity = value
	brushColor = Color(brushColor.r, brushColor.g, brushColor.b, value)
	
	

# Hex shading code from https://github.com/rvanwijnen/spectral.js/blob/main/python/spectral.py
# NOT IN USE

const SIZE = 38
const GAMMA = 2.4
const EPSILON = 0.00000001

var SPD_C = [0.96853629, 0.96855103, 0.96859338, 0.96877345, 0.96942204, 0.97143709, 0.97541862, 0.98074186, 0.98580992, 0.98971194, 0.99238027, 0.99409844, 0.995172, 0.99576545, 0.99593552, 0.99564041, 0.99464769, 0.99229579, 0.98638762, 0.96829712, 0.89228016, 0.53740239, 0.15360445, 0.05705719, 0.03126539, 0.02205445, 0.01802271, 0.0161346, 0.01520947, 0.01475977, 0.01454263, 0.01444459, 0.01439897, 0.0143762, 0.01436343, 0.01435687, 0.0143537, 0.01435408]
var SPD_M = [0.51567122, 0.5401552, 0.62645502, 0.75595012, 0.92826996, 0.97223624, 0.98616174, 0.98955255, 0.98676237, 0.97312575, 0.91944277, 0.32564851, 0.13820628, 0.05015143, 0.02912336, 0.02421691, 0.02660696, 0.03407586, 0.04835936, 0.0001172, 0.00008554, 0.85267882, 0.93188793, 0.94810268, 0.94200977, 0.91478045, 0.87065445, 0.78827548, 0.65738359, 0.59909403, 0.56817268, 0.54031997, 0.52110241, 0.51041094, 0.50526577, 0.5025508, 0.50126452, 0.50083021]
var SPD_Y = [0.02055257, 0.02059936, 0.02062723, 0.02073387, 0.02114202, 0.02233154, 0.02556857, 0.03330189, 0.05185294, 0.10087639, 0.24000413, 0.53589066, 0.79874659, 0.91186529, 0.95399623, 0.97137099, 0.97939505, 0.98345207, 0.98553736, 0.98648905, 0.98674535, 0.98657555, 0.98611877, 0.98559942, 0.98507063, 0.98460039, 0.98425301, 0.98403909, 0.98388535, 0.98376116, 0.98368246, 0.98365023, 0.98361309, 0.98357259, 0.98353856, 0.98351247, 0.98350101, 0.98350852]
var SPD_R = [0.03147571, 0.03146636, 0.03140624, 0.03119611, 0.03053888, 0.02856855, 0.02459485, 0.0192952, 0.01423112, 0.01033111, 0.00765876, 0.00593693, 0.00485616, 0.00426186, 0.00409039, 0.00438375, 0.00537525, 0.00772962, 0.0136612, 0.03181352, 0.10791525, 0.46249516, 0.84604333, 0.94275572, 0.96860996, 0.97783966, 0.98187757, 0.98377315, 0.98470202, 0.98515481, 0.98537114, 0.98546685, 0.98550011, 0.98551031, 0.98550741, 0.98551323, 0.98551563, 0.98551547]
var SPD_G = [0.49108579, 0.46944057, 0.4016578, 0.2449042, 0.0682688, 0.02732883, 0.013606, 0.01000187, 0.01284127, 0.02636635, 0.07058713, 0.70421692, 0.85473994, 0.95081565, 0.9717037, 0.97651888, 0.97429245, 0.97012917, 0.9425863, 0.99989207, 0.99989891, 0.13823139, 0.06968113, 0.05628787, 0.06111561, 0.08987709, 0.13656016, 0.22169624, 0.32176956, 0.36157329, 0.4836192, 0.46488579, 0.47440306, 0.4857699, 0.49267971, 0.49625685, 0.49807754, 0.49889859]
var SPD_B = [0.97901834, 0.97901649, 0.97901118, 0.97892146, 0.97858555, 0.97743705, 0.97428075, 0.96663223, 0.94822893, 0.89937713, 0.76070164, 0.4642044, 0.20123039, 0.08808402, 0.04592894, 0.02860373, 0.02060067, 0.01656701, 0.01451549, 0.01357964, 0.01331243, 0.01347661, 0.01387181, 0.01435472, 0.01479836, 0.0151525, 0.01540513, 0.01557233, 0.0156571, 0.01571025, 0.01571916, 0.01572133, 0.01572502, 0.01571717, 0.01571905, 0.01571059, 0.01569728, 0.0157002]
var CIE_CMF_X = [0.00006469, 0.00021941, 0.00112057, 0.00376661, 0.01188055, 0.02328644, 0.03455942, 0.03722379, 0.03241838, 0.02123321, 0.01049099, 0.00329584, 0.00050704, 0.00094867, 0.00627372, 0.01686462, 0.02868965, 0.04267481, 0.05625475, 0.0694704, 0.08305315, 0.0861261, 0.09046614, 0.08500387, 0.07090667, 0.05062889, 0.03547396, 0.02146821, 0.01251646, 0.00680458, 0.00346457, 0.00149761, 0.0007697, 0.00040737, 0.00016901, 0.00009522, 0.00004903, 0.00002]
var CIE_CMF_Y = [0.00000184, 0.00000621, 0.00003101, 0.00010475, 0.00035364, 0.00095147, 0.00228226, 0.00420733, 0.0066888, 0.0098884, 0.01524945, 0.02141831, 0.03342293, 0.05131001, 0.07040208, 0.08783871, 0.09424905, 0.09795667, 0.09415219, 0.08678102, 0.07885653, 0.0635267, 0.05374142, 0.04264606, 0.03161735, 0.02088521, 0.01386011, 0.00810264, 0.0046301, 0.00249138, 0.0012593, 0.00054165, 0.00027795, 0.00014711, 0.00006103, 0.00003439, 0.00001771, 0.00000722]
var CIE_CMF_Z = [0.00030502, 0.00103681, 0.00531314, 0.01795439, 0.05707758, 0.11365162, 0.17335873, 0.19620658, 0.18608237, 0.13995048, 0.08917453, 0.04789621, 0.02814563, 0.01613766, 0.0077591, 0.00429615, 0.00200551, 0.00086147, 0.00036904, 0.00019143, 0.00014956, 0.00009231, 0.00006813, 0.00002883, 0.00001577, 0.00000394, 0.00000158, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var XYZ_RGB = [[3.24306333, -1.53837619, -0.49893282], [-0.96896309, 1.87542451, 0.04154303], [0.05568392, -0.20417438, 1.05799454]]

func linear_to_concentration(l1, l2, t):
	var t1 = l1 * (1 - t) ** 2
	var t2 = l2 * t ** 2
	return t2 / (t1 + t2)
	
func spectral_mix(color1, color2, t):
	var lrgb1 = srgb_to_linear(color1)
	var lrgb2 = srgb_to_linear(color2)
	var R1 = linear_to_reflectance(lrgb1)
	var R2 = linear_to_reflectance(lrgb2)
	var l1 = dotproduct(R1, CIE_CMF_Y)
	var l2 = dotproduct(R2, CIE_CMF_Y)
	t = linear_to_concentration(l1, l2, t)
	var R = []
	for i in range(SIZE):
		var KS = (1 - t) * ((1 - R1[i]) ** 2 / (2 * R1[i])) + t * ((1 - R2[i]) ** 2 / (2 * R2[i]))
		var KM = 1 + KS - (KS ** 2 + 2 * KS) ** 0.5
		R.append(KM)
	var xyz = reflectance_to_xyz(R)
	return xyz_to_srgb(xyz)
	
func uncompand(x):
	return x / 12.92 if x < 0.04045 else ((x + 0.055) / 1.055) ** GAMMA
	
func compand(x):
	return x * 12.92 if x < 0.0031308 else 1.055 * x ** (1.0 / GAMMA) - 0.055
	
func srgb_to_linear(srgb):
	var r = uncompand(srgb[0] / 255)
	var g = uncompand(srgb[1] / 255)
	var b = uncompand(srgb[2] / 255)
	return [r, g, b]
	
func linear_to_srgb(lrgb):
	var r = compand(lrgb[0])
	var g = compand(lrgb[1])
	var b = compand(lrgb[2])
	return [round(clamp(r, 0, 1) * 255), round(clamp(g, 0, 1) * 255), round(clamp(b, 0, 1) * 255)]
	 
func reflectance_to_xyz(R):
	var x = dotproduct(R, CIE_CMF_X)
	var y = dotproduct(R, CIE_CMF_Y)
	var z = dotproduct(R, CIE_CMF_Z)
	return [x, y, z]
	
func xyz_to_srgb(xyz):
	var r = dotproduct(XYZ_RGB[0], xyz)
	var g = dotproduct(XYZ_RGB[1], xyz)
	var b = dotproduct(XYZ_RGB[2], xyz)
	return linear_to_srgb([r, g, b])
	
func spectral_upsampling(lrgb):
	var w = min(min(lrgb[0], lrgb[1]), lrgb[2])
	lrgb = [lrgb[0] - w, lrgb[1] - w, lrgb[2] - w]
	var c = min(lrgb[1], lrgb[2])
	var m = min(lrgb[0], lrgb[2])
	var y = min(lrgb[0], lrgb[1])
	var r = max(0, min(lrgb[0] - lrgb[2], lrgb[0] - lrgb[1]))
	var g = max(0, min(lrgb[1] - lrgb[2], lrgb[1] - lrgb[0]))
	var b = max(0, min(lrgb[2] - lrgb[1], lrgb[2] - lrgb[0]))
	return [w, c, m, y, r, g, b]
	
func linear_to_reflectance(lrgb):
	var weights = spectral_upsampling(lrgb)
	var R = []
	for i in range(SIZE):
		R.append(
			max(EPSILON,
				weights[0]
				+ weights[1] * SPD_C[i]
				+ weights[2] * SPD_M[i]
				+ weights[3] * SPD_Y[i]
				+ weights[4] * SPD_R[i]
				+ weights[5] * SPD_G[i]
				+ weights[6] * SPD_B[i]
			)
		)
	return R
	
func dotproduct(a, b):
	var result = 0.0
	for i in range(a.size()):
		result += a[i] * b[i]
	return result
	
func clamp(value, min_value, max_value):
	return min(max(value, min_value), max_value)
