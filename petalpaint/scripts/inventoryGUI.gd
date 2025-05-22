extends Control

enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, HONEY}
var red = "res://assets/exploreAssets/flowerRed.png"
var yel = "res://assets/exploreAssets/flowerYel Icon.png"
var blu = "res://assets/exploreAssets/flowerBlu.png"
var blk = "res://assets/exploreAssets/blkCoal.png"
var wht = "res://assets/exploreAssets/whtTitatium.png"
@onready var backBtn = $BackBtn
@onready var optionsBtn = $OptionsBtn
@onready var dayNightBtn = $DayNightBtn
@onready var grayscaleBtn = $GrayscaleBtn
@onready var redBox = $HotbarContainer/c/RedBox
@onready var yelBox = $HotbarContainer/c2/YelBox
@onready var bluBox = $HotbarContainer/c3/BluBox
@onready var blkBox = $HotbarContainer/c4/BlkBox
@onready var whtBox = $HotbarContainer/c5/WhtBox
@onready var honey = %HoneyMeter
@onready var gameManager: Node = %GameManager

func _ready() -> void:
	# connect buttons
	backBtn.pressed.connect(backBtnPressed)
	optionsBtn.pressed.connect(optionsBtnPressed)
	dayNightBtn.pressed.connect(dayNightBtnPressed)
	grayscaleBtn.pressed.connect(grayscaleBtnPressed)
	
	# Load HotBar textures:
	var tempTexture = redBox.get_node("Texture")
	tempTexture.texture = load(red)
	tempTexture = yelBox.get_node("Texture")
	tempTexture.texture = load(yel)
	tempTexture = bluBox.get_node("Texture")
	tempTexture.texture = load(blu)
	tempTexture = blkBox.get_node("Texture")
	tempTexture.texture = load(blk)
	tempTexture = whtBox.get_node("Texture")
	tempTexture.texture = load(wht)
	
	updateAllLabels()


func backBtnPressed():
	get_tree().change_scene_to_file("res://scenes/GUI/mainMenu.tscn")


func optionsBtnPressed():
	# open options GUI by calling from exploration.gd
	gameManager.toggleOptionsGUI()


func dayNightBtnPressed():
	gameManager.toggleDayNight()


func grayscaleBtnPressed():
	gameManager.toggleGrayscale()


func updateLabel(color: int, amount: int):
	var tempLabel
	match color:
		COLORS.RED:
			tempLabel = redBox.get_node("Label")
		COLORS.YEL:
			tempLabel = yelBox.get_node("Label")
		COLORS.BLU:
			tempLabel = bluBox.get_node("Label")
		COLORS.BLK:
			tempLabel = blkBox.get_node("Label")
		COLORS.WHT:
			tempLabel = whtBox.get_node("Label")
			
	tempLabel.text = str(amount)


func updateAllLabels():
	var tempLabel
	tempLabel = redBox.get_node("Label")
	tempLabel.text = str(gameManager.materialInv[COLORS.RED])
	tempLabel = yelBox.get_node("Label")
	tempLabel.text = str(gameManager.materialInv[COLORS.YEL])
	tempLabel = bluBox.get_node("Label")
	tempLabel.text = str(gameManager.materialInv[COLORS.BLU])
	tempLabel = blkBox.get_node("Label")
	tempLabel.text = str(gameManager.materialInv[COLORS.BLK])
	tempLabel = whtBox.get_node("Label")
	tempLabel.text = str(gameManager.materialInv[COLORS.WHT])
	honey.value = gameManager.materialInv[COLORS.HONEY]


func updateHoneyMeter(amount: int):
	honey.value += amount
