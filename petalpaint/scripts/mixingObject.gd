# Handles the color-changing textures for a material instantiated in the mortar
extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var symbol = $Symbol
@onready var collider = $CollisionShape2D
@onready var player = find_parent("Player")
@onready var paintTableGUI = find_parent("PaintTableGUI")
var hits = 10
var slabHits = 3
enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, HONEY}
var hexColors = [0xf04c4bff, 0xec9944ff, 0xdeca33ff, 0x25e161ff, 0x4fbeffff, 0x9130e6ff, 0x2c2c2cff, 0xffffffff]
@export var color: COLORS
var localPos
var isActive = true # whether the GUI is active -> helps determine when to set the RigidBody2D location
var isInSpoon = false
var isFollowingSpoon = false
var spoonOffset # global offset for following spoon
var isPowder = false
var isInGlassMuller = false

# Loading assets variables
var red = "res://assets/exploreAssets/flowerRed.png"
var yel = "res://assets/exploreAssets/flowerYel Icon.png"
var blu = "res://assets/exploreAssets/flowerBlu.png"
var blk = "res://assets/exploreAssets/blkCoal.png"
var wht = "res://assets/exploreAssets/whtTitatium.png"

func _ready() -> void:
	# Load correct texture
	match color:
		COLORS.RED:
			sprite.texture = load(red)
		COLORS.YEL:
			sprite.texture = load(yel)
		COLORS.BLU:
			sprite.texture = load(blu)
		COLORS.BLK:
			sprite.texture = load(blk)
		COLORS.WHT:
			sprite.texture = load(wht)


func _process(_delta):
	if(!isActive):
		self.global_transform.origin = localPos + player.position
		self.freeze = true
	else:
		self.freeze = false
		if(isFollowingSpoon):
			self.global_transform.origin = get_global_mouse_position() + spoonOffset


func setLocalPos():
	localPos = self.global_transform.origin - player.global_transform.origin
	print(localPos)


func decreaseHit():
	if(hits == -1):
		return
		
	if(hits == 5): # change sprite to powder of designated color
		sprite.texture = load("res://assets/GUI/PaintMaking/powder.png")
		changeSpriteSymbol()
		changeSpriteColor()
		symbol.set_visible(true)
		if(paintTableGUI.mixingColor == COLORS.RED || paintTableGUI.mixingColor == COLORS.YEL || paintTableGUI.mixingColor == COLORS.BLU || paintTableGUI.mixingColor == COLORS.BLK || paintTableGUI.mixingColor == COLORS.WHT):
			hits = 0 # no more mixing needed
	if(hits == 0):
		isPowder = true
		color = paintTableGUI.mixingColor
		changeSpriteColor() # change to the final color
		changeSpriteSymbol()
	hits -= 1


func decreaseSlabHit():
	if(slabHits == -1):
		return
		
	if(slabHits == 0): # change sprite to powder of designated color
		self.queue_free()
	
	slabHits -= 1

func followSpoon():
	if(!isFollowingSpoon):
		spoonOffset = self.global_transform.origin - get_global_mouse_position()
		isFollowingSpoon = true
		collider.call_deferred("set_disabled", true)
	else:
		print("already following spoon")


func detachFromSpoon():
	isFollowingSpoon = false
	isInGlassMuller = true
	print("detached from spoon")
	paintTableGUI.isMortarEmpty()
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, true)
	collider.call_deferred("set_disabled", false)


func changeSpriteColor():
	match color:
		COLORS.RED:
			sprite.modulate = Color.hex(hexColors[COLORS.RED])
		COLORS.ORG:
			sprite.modulate = Color.hex(hexColors[COLORS.ORG])
		COLORS.YEL:
			sprite.modulate = Color.hex(hexColors[COLORS.YEL])
		COLORS.GRN:
			sprite.modulate = Color.hex(hexColors[COLORS.GRN])
		COLORS.BLU:
			sprite.modulate = Color.hex(hexColors[COLORS.BLU])
		COLORS.PUR:
			sprite.modulate = Color.hex(hexColors[COLORS.PUR])
		COLORS.BLK:
			sprite.modulate = Color.hex(hexColors[COLORS.BLK])
		COLORS.WHT:
			sprite.modulate = Color.hex(hexColors[COLORS.WHT])


func changeSpriteSymbol():
	match color:
		COLORS.RED:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/REDsymbol.PNG")
		COLORS.ORG:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/ORGsymbol.PNG")
		COLORS.YEL:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/YELsymbol.PNG")
		COLORS.GRN:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/GRNsymbol.PNG")
		COLORS.BLU:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/BLUsymbol.PNG")
		COLORS.PUR:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/PURsymbol.PNG")
		COLORS.BLK:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/BLKsymbol.PNG")
		COLORS.WHT:
			symbol.texture = load("res://assets/GUI/PaintMaking/symbols/WHTsymbol.PNG")
