extends Control

# handles symbols on the interactive paint inventory

enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, HONEY}
var unlocked = [0,0,0,0,0,0,0,0]
@onready var red = $HotbarContainer/RED/REDBottle/SymbolArea
@onready var org = $HotbarContainer/ORG/ORGBottle/SymbolArea
@onready var yel = $HotbarContainer/YEL/YELBottle/SymbolArea
@onready var grn = $HotbarContainer/GRN/GRNBottle/SymbolArea
@onready var blu = $HotbarContainer/BLU/BLUBottle/SymbolArea
@onready var pur = $HotbarContainer/PUR/PURBottle/SymbolArea
@onready var blk = $HotbarContainer/BLK/BLKBottle/SymbolArea
@onready var wht = $HotbarContainer/WHT/WHTBottle/SymbolArea


func _ready() -> void:
	loadInventorySymbols()


func loadUnlocked(arr: Array):
	for x in range(0,8):
		unlocked[x] = arr[x]
	loadInventorySymbols()


func loadInventorySymbols():
	for x in range(0,8):
		loadSymbol(x)


func loadSymbol(color: COLORS):
	if(unlocked[color] == -1):
		return
	var tempSymbol
	match color:
		COLORS.RED:
			tempSymbol = red.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/REDsymbol.PNG")
		COLORS.ORG:
			tempSymbol = org.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/ORGsymbol.PNG")
		COLORS.YEL:
			tempSymbol = yel.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/YELsymbol.PNG")
		COLORS.GRN:
			tempSymbol = grn.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/GRNsymbol.PNG")
		COLORS.BLU:
			tempSymbol = blu.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/BLUsymbol.PNG")
		COLORS.PUR:
			tempSymbol = pur.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/PURsymbol.PNG")
		COLORS.BLK:
			tempSymbol = blk.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/BLKsymbol.PNG")
		COLORS.WHT:
			tempSymbol = wht.get_node("Sprite2D")
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/WHTsymbol.png")
