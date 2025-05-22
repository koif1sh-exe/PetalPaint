extends Control

enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT}

var red = "res://assets/exploreAssets/flowerRed.png"
var yel = "res://assets/exploreAssets/flowerYel.png"
var blu = "res://assets/exploreAssets/flowerBlu.png"
var blk = "res://assets/exploreAssets/blkCoal.png"
var wht = "res://assets/exploreAssets/whtTitanium.png"
@onready var texture = $Texture
@export var color: COLORS = 0

func _ready() -> void:
	match COLORS:
		1:
			texture.texture = load(red)
		3:
			texture.texutre = load(yel)
		5:
			texture.texutre = load(blu)
		7:
			texture.texutre = load(blk)
		8:
			texture.texutre = load(wht)

func _process(delta: float) -> void:
	#texture.texture = load(red)
	pass
