extends Node

var materialInv = [6,6,6,6,6,6,6,6,25] # red, org, yel, grn, blu, pur, blk, wht, honey
var paintInv = [10,10,10,0,10,10,10,10,10]
enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, HONEY}
@onready var inventoryGUI: Node = %InventoryGUI
@onready var optionsGUI: Node = %OptionsGUI
@onready var player: Node = %Player
@onready var dayNight = %DayNight
@onready var grayscale = %Grayscale
@onready var playerLight = %PlayerLight
@onready var optionsBackBtn = %OptionsGUI/BackBtn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	optionsBackBtn.pressed.connect(optionsBackBtnPressed)


func optionsBackBtnPressed():
	optionsGUI.visible = false
	player.canWalk = true

func addMaterial(color: COLORS):
	materialInv[color] += 1;
	print(materialInv[color])
	inventoryGUI.updateLabel(color, materialInv[color])


func getMaterials():
	return materialInv


func toggleOptionsGUI():
	if(optionsGUI.visible == true):
		player.canWalk = true
		optionsGUI.visible = false
	else:
		optionsGUI.visible = true
		player.canWalk = false


func toggleDayNight():
	if(dayNight.visible == true):
		#playerLight.visible = false
		dayNight.visible = false
	else:
		#playerLight.visible = true
		dayNight.visible = true
	pass


func toggleGrayscale():
	if(grayscale.visible == true):
		grayscale.visible = false
	else:
		grayscale.visible = true
	pass
