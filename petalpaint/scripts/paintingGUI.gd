extends Control

enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, HONEY}

@onready var opacityLabel = %OpacityLabel
@onready var sizeLabel = %SizeLabel
@onready var player: Node = %Player
@onready var inventoryGUI: Control = %InventoryGUI
@onready var paintInventory = %PaintInteract
@onready var gameManager: Node = %GameManager

func _ready() -> void:
	paintInventory.loadUnlocked(gameManager.paintInv)


#func loadPaintInventoryAll():
	#for x: int in range(0,8):
		#loadPaintInventory(x)
#
#
##func loadPaintInventory(color: int):
	##var tempNode
	##match color:
		##COLORS.RED:
			##tempNode = paintInventory.get_node("HotbarContainer/RED/REDBottle/REDPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.RED]
		##COLORS.ORG:
			##tempNode = paintInventory.get_node("HotbarContainer/ORG/ORGBottle/ORGPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.ORG]
		##COLORS.YEL:
			##tempNode = paintInventory.get_node("HotbarContainer/YEL/YELBottle/YELPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.YEL]
		##COLORS.GRN:
			##tempNode = paintInventory.get_node("HotbarContainer/GRN/GRNBottle/GRNPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.GRN]
		##COLORS.BLU:
			##tempNode = paintInventory.get_node("HotbarContainer/BLU/BLUBottle/BLUPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.BLU]
		##COLORS.PUR:
			##tempNode = paintInventory.get_node("HotbarContainer/PUR/PURBottle/PURPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.PUR]
		##COLORS.BLK:
			##tempNode = paintInventory.get_node("HotbarContainer/BLK/BLKBottle/BLKPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.BLK]
		##COLORS.WHT:
			##tempNode = paintInventory.get_node("HotbarContainer/WHT/WHTBottle/WHTPaintSlider")
			##tempNode.value = gameManager.paintInv[COLORS.WHT]

func _on_opacity_slider_value_changed(value: float) -> void:
	opacityLabel.text = str(value)


func _on_size_slider_value_changed(value: float) -> void:
	sizeLabel.text = str(value)


func _on_back_btn_pressed() -> void:
	inventoryGUI.set_visible(true)
	set_visible(false)
	inventoryGUI.updateAllLabels()
	player.canWalk = true
