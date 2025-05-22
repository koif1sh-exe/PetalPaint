extends Control

# Main variables
enum COLORS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, HONEY}
enum TOOLS {KNIFE, SPOON, PESTLE, MULLER, PIPETTE, NONE}
enum PHASE {SELECT, MIX, SPOON, HONEY, MULLER, KNIFE, ADDPAINT, NONE}
var hexColors = [0xf04c4bff, 0xec9944ff, 0xdeca33ff, 0x25e161ff, 0x4fbeffff, 0x9130e6ff, 0x2c2c2cff, 0xffffffff]
@onready var backBtn = %BackBtn
@onready var inventoryGUI: Control = %InventoryGUI
@onready var paletteKnife = %PaletteKnife
@onready var spoon = %Spoon
@onready var pestle = %Pestle
@onready var glassMuller = %GlassMuller
@onready var pipette = %Pipette
@onready var bowlMaterials = $BowlMaterials # Folder containing all materials in the mortar
@onready var slot0 = $Slot0
@onready var slot1 = $Slot1
@onready var glassSlabCanvas = %GlassSlabCanvas

# Loading asset variables
var red = "res://assets/exploreAssets/flowerRed.png"
var yel = "res://assets/exploreAssets/flowerYel Icon.png"
var blu = "res://assets/exploreAssets/flowerBlu.png"
var blk = "res://assets/exploreAssets/blkCoal.png"
var wht = "res://assets/exploreAssets/whtTitatium.png"
@onready var redBox = $HotbarContainer/c/RedBox
@onready var yelBox = $HotbarContainer/c2/YelBox
@onready var bluBox = $HotbarContainer/c3/BluBox
@onready var blkBox = $HotbarContainer/c4/BlkBox
@onready var whtBox = $HotbarContainer/c5/WhtBox
@onready var honey = %HoneyMeterSlider
@onready var gameManager: Node = %GameManager
@onready var player: Node = %Player
@onready var paintInventory: Node = %PaintInventory
@onready var mixingObject = preload("res://scenes/objects/mixingObject.tscn")

# Misc variables
var currTool = TOOLS.NONE
var currPhase = PHASE.SELECT
var prevPosition
var degrees = 16 # the rotation of the tool when it is picked up
var disp = 40 # displacement in the mortar
var rng = RandomNumberGenerator.new()
var slots = [-1,-1] # colors in the Slot0 and Slot1
var slotAmounts = [0,0] # amounts of colors in slots
var mixingColor # The predicted mixing color
var mixingAmount # predicted mixing amount
var materialAmount = 4 # amount of paint output per material added to the bowl
var inGlassSlab = false; # true when the spoon is above the glass slab
var objectsDespawned = false
var inHoneyBottle = false


func _ready() -> void:
	# Decrease alpha to 0 for area buttons
	$GlassMullerBtn.modulate.a = 0
	$SpoonBtn.modulate.a = 0
	$PestleBtn.modulate.a = 0
	$PaletteKnifeBtn.modulate.a = 0
	$PipetteBtn.modulate.a = 0
	$HotbarContainer/c/RedBox/RedBoxBtn.modulate.a = 0
	$HotbarContainer/c2/YelBox/YelBoxBtn.modulate.a = 0
	$HotbarContainer/c3/BluBox/BluBoxBtn.modulate.a = 0
	$HotbarContainer/c4/BlkBox/BlkBoxBtn.modulate.a = 0
	$HotbarContainer/c5/WhtBox/WhtBoxBtn.modulate.a = 0
	$Slot0Btn.modulate.a = 0
	$Slot1Btn.modulate.a = 0
	
	# Load HotBar textures and values:
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
	
	loadPaintInventoryAll()


func _physics_process(_delta):
	var mouseposition = get_local_mouse_position()
	match currTool:
		TOOLS.KNIFE:
			paletteKnife.position = mouseposition
		TOOLS.SPOON:
			spoon.position = mouseposition
		TOOLS.PESTLE:
			pestle.position = mouseposition
		TOOLS.MULLER:
			glassMuller.position = mouseposition
		TOOLS.PIPETTE:
			pipette.position = mouseposition


func _input(event): # Handle collider activation
	var tempCollider2D
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		match currTool:
			TOOLS.SPOON:
				if(inGlassSlab):
					print("inGlassSlab = true")
					for child in bowlMaterials.get_children():
						if(child.isFollowingSpoon == true):
							child.detachFromSpoon()
				else:
					print("inGlassSlab = false")
					for child in bowlMaterials.get_children():
						if(child.isInSpoon == true && child.isPowder == true):
							child.followSpoon()
			TOOLS.PIPETTE:
				if(inHoneyBottle && currPhase == PHASE.HONEY):
					$Pipette/PipetteSprite.texture = load("res://assets/GUI/PaintMaking/pipetteFilled.png")
					gameManager.materialInv[COLORS.HONEY] -= 2
					currPhase = PHASE.MULLER
				elif(currPhase == PHASE.MULLER && inGlassSlab):
					$Pipette/PipetteSprite.texture = load("res://assets/GUI/PaintMaking/pipette.png")


	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		match currTool:
			TOOLS.PESTLE:
				tempCollider2D = pestle.get_node("CollisionShape2D")
				tempCollider2D.set_disabled(false)
			TOOLS.MULLER:
				tempCollider2D = glassMuller.get_node("CollisionShape2D")
				tempCollider2D.set_disabled(false)
			
	else:
		match currTool:
			TOOLS.PESTLE:
				tempCollider2D = pestle.get_node("CollisionShape2D")
				tempCollider2D.set_disabled(true)
			TOOLS.MULLER:
				tempCollider2D = glassMuller.get_node("CollisionShape2D")
				tempCollider2D.set_disabled(true)


# updates the label in the inventory
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


func setValues():
	# Update labels
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
	print("honey value is " + str(gameManager.materialInv[COLORS.HONEY]))


func selectTool(tool: TOOLS):
	if(currTool != tool): # select tool
		returnTool()
		currTool = tool
		match tool:
			TOOLS.KNIFE:
				paletteKnife.rotation += deg_to_rad(-degrees)
				glassSlabCanvas.setIsErasing()
			TOOLS.SPOON:
				spoon.rotation += deg_to_rad(-degrees)
			TOOLS.PESTLE:
				pestle.rotation += deg_to_rad(-degrees) 
			TOOLS.MULLER:
				if(currPhase == PHASE.MULLER):
					glassSlabCanvas.setIsDrawing()
					glassSlabCanvas.setColor(hexColors[mixingColor])
					print("setting brush mixing color")
			TOOLS.PIPETTE:
				pipette.rotation += deg_to_rad(degrees) 
	else:
		returnTool()


func returnTool():
	match currTool:
		TOOLS.KNIFE:
			paletteKnife.position = prevPosition
			paletteKnife.rotation += deg_to_rad(degrees)
			glassSlabCanvas.setIsNothing()
		TOOLS.SPOON:
			spoon.position = prevPosition
			spoon.rotation += deg_to_rad(degrees)
		TOOLS.PESTLE:
			pestle.position = prevPosition
			pestle.rotation += deg_to_rad(degrees) 
		TOOLS.MULLER:
			glassMuller.position = prevPosition
			glassSlabCanvas.setIsNothing()
		TOOLS.PIPETTE:
			pipette.position = prevPosition
			pipette.rotation += deg_to_rad(-degrees) 
			
	currTool = TOOLS.NONE


func _on_pestle_body_entered(body: Node2D) -> void:
	if(mixingColor == -1 || currPhase == PHASE.MULLER):
		return
	if body.is_in_group("BowlMaterials"):
		var push_force = 300
		currPhase = PHASE.MIX;
		
		if body is RigidBody2D:
			body.apply_central_impulse((get_local_mouse_position() - pestle.position).normalized() * (push_force + rng.randf_range(-200.0, 50.0)))
			body.decreaseHit()


func _on_glass_muller_body_entered(body: Node2D) -> void:
	if(currPhase != PHASE.MULLER):
		return
	if body.is_in_group("BowlMaterials"):
		var push_force = 200
		
		if body is RigidBody2D:
			body.apply_central_impulse((get_local_mouse_position() - pestle.position).normalized() * (push_force + rng.randf_range(-200.0, 50.0)))
			body.decreaseSlabHit()

func addToMortar(color: COLORS):
	if(currPhase != PHASE.SELECT):
		print("cannot add mixingObject after mixing")
		return
	
	if(gameManager.materialInv[color] > 0):
		# set the slot if applicable
		# OR instantiate material if color matches
		
		if(color == slots[0]):
			incrementSlot(0)
			instantiateObject(color)
		elif(color == slots[1]):
			incrementSlot(1)
			instantiateObject(color)
		elif(getFreeSlot() == 0):
			setSlot(0,color)
			incrementSlot(0)
			instantiateObject(color)
		elif(getFreeSlot() == 1):
			setSlot(1,color)
			incrementSlot(1)
			instantiateObject(color)
		
		else:
			print("all slots taken")
	else:
		print("Not enough " + str(color))


func removeFromMortar(color: COLORS):
	# uninstantiate object that isn't already grounded up
	if(currPhase != PHASE.SELECT):
		print("cannot remove mixingObject after mixing")
		return
	uninstantiateObject(color)


func isMortarEmpty():
	for child in bowlMaterials.get_children():
		if(child.isInGlassMuller == false):
			print("mortar is not empty")
			return
			
	print("mortar empty: entering muller phase")
	currPhase = PHASE.HONEY


func instantiateObject(color: COLORS):
	var instance = mixingObject.instantiate()
	instance.color = color
	instance.position = Vector2(396 + rng.randf_range(-disp, disp),336 + rng.randf_range(-disp, disp))
	bowlMaterials.add_child(instance)
	gameManager.materialInv[color] -= 1
	updateLabel(color,gameManager.materialInv[color])
	setMixingColor()


func uninstantiateObject(color: COLORS):
	for child in bowlMaterials.get_children():
		if(child.color == color):
			if(color == slots[0]):
				decrementSlot(0)
				gameManager.materialInv[color] += 1
				updateLabel(color,gameManager.materialInv[color])
			elif(color == slots[1]):
				decrementSlot(1)
				gameManager.materialInv[color] += 1
				updateLabel(color,gameManager.materialInv[color])
			child.queue_free()
	setMixingColor() # clear bottle


func despawnBowlMaterials():
	for child in bowlMaterials.get_children():
		child.queue_free()


func getColorTextureIcon(color: COLORS):
	match color:
		COLORS.RED:
			return red
		COLORS.YEL:
			return yel
		COLORS.BLU:
			return blu
		COLORS.BLK:
			return blk
		COLORS.WHT:
			return wht


func _on_spoon_body_entered(body: Node2D) -> void:
	if body.is_in_group("BowlMaterials"):
		if body is RigidBody2D:
			body.isInSpoon = true


func _on_spoon_body_exited(body: Node2D) -> void:
	if body.is_in_group("BowlMaterials"):
		if body is RigidBody2D:
			body.isInSpoon = false


func _on_honey_meter_area_entered(area: Area2D) -> void:
	if(area.name == "Pipette"):
		inHoneyBottle = true


func _on_honey_meter_area_exited(area: Area2D) -> void:
	if(area.name == "Pipette"):
		inHoneyBottle = false


func _on_glass_slab_area_entered(area: Area2D) -> void:
	print("entered glass slab: " + str(area) )
	if(area.name == "Spoon" || area.name == "Pipette"):
		inGlassSlab = true


func _on_glass_slab_area_exited(area: Area2D) -> void:
	if(area.name == "Spoon" || area.name == "Pipette"):
		inGlassSlab = false



# returns the slot available, -1 if none	
func getFreeSlot() -> int:
	if(slots[0] == -1):
		return 0
	elif(slots[1] == -1):
		return 1
	return -1


# sets the slot's texture and arrays
func setSlot(num: int, color: COLORS):
	if(num == 0):
		# load texture
		print("loading slot 0")
		slots[0] = color
		var tempTexture = slot0.get_node("Texture")
		tempTexture.texture = load(getColorTextureIcon(color))
	elif(num == 1):
		print("loading slot 1")
		slots[1] = color
		var tempTexture = slot1.get_node("Texture")
		tempTexture.texture = load(getColorTextureIcon(color))


# increments the slot's label and amount
func incrementSlot(num: int):
	var tempLabel
	if(num == 0):
		slotAmounts[0] += 1
		tempLabel = slot0.get_node("Label")
		tempLabel.text = str(slotAmounts[0])
	else:
		slotAmounts[1] += 1
		tempLabel = slot1.get_node("Label")
		tempLabel.text = str(slotAmounts[1])


# decrements the slot's label and amount
func decrementSlot(num: int):
	var tempLabel
	if(num == 0):
		slotAmounts[0] -= 1
		tempLabel = slot0.get_node("Label")
		tempLabel.text = str(slotAmounts[0])
		if(slotAmounts[0] == 0):
			clearSlot(0)
	elif(num == 1):
		slotAmounts[1] -= 1
		tempLabel = slot1.get_node("Label")
		tempLabel.text = str(slotAmounts[1])	
		if(slotAmounts[1] == 0):
			clearSlot(1)


func clearSlot(num: int):
	# set texture to nothing
	if(num == 0):
		var tempTexture = slot0.get_node("Texture")
		tempTexture.texture = null
		slots[0] = -1
		slotAmounts[0] = 0
		var tempLabel = slot0.get_node("Label")
		tempLabel.text = str(0)
	elif(num == 1):
		var tempTexture = slot1.get_node("Texture")
		tempTexture.texture = null
		slots[1] = -1
		slotAmounts[1] = 0
		var tempLabel = slot1.get_node("Label")
		tempLabel.text = str(0)


# updates the predicted color based on the colors in the slots
func setMixingColor():
	if(slots[0] != -1 && slots[1] != -1): # both slots are filled
		# Orange:
		if(slots[0] == COLORS.RED && slots[1] == COLORS.YEL):
			mixingColor = COLORS.ORG
		elif(slots[0] == COLORS.YEL && slots[1] == COLORS.RED):
			mixingColor = COLORS.ORG
		# Green:
		elif(slots[0] == COLORS.YEL && slots[1] == COLORS.BLU):
			mixingColor = COLORS.GRN
		elif(slots[0] == COLORS.BLU && slots[1] == COLORS.YEL):
			mixingColor = COLORS.GRN
		# Purple
		elif(slots[0] == COLORS.RED && slots[1] == COLORS.BLU):
			mixingColor = COLORS.PUR
		elif(slots[0] == COLORS.BLU && slots[1] == COLORS.RED):
			mixingColor = COLORS.PUR
		# None
		else:
			mixingColor = -1
	elif(slots[0] != -1):
		mixingColor = slots[0]
	elif(slots[1] != -1):
		mixingColor = slots[1]
	else: # empty slots
		mixingColor = -1
	
	updateBottle(mixingColor)


func updateBottle(color: COLORS):	
	print("updating prediction")
	var tempSymbol = $PredictionBottle/PredictionBottleSymbol # update symbol
	var tempSlider = $PredictionBottle/PredictionPaintSlider # update color
	
	if(color == -1):
		tempSymbol.texture = null;
		tempSlider.add_theme_stylebox_override("grabber_area", StyleBoxFlat.new())
		return
		
	var style = StyleBoxFlat.new() # cuz im too lazy to figure out themes rn
	style.set_corner_radius_all(5)
	style.set_expand_margin(SIDE_LEFT, 18)
	style.set_expand_margin(SIDE_RIGHT, 18)
	tempSlider.add_theme_stylebox_override("grabber_area", style)
	mixingAmount = (slotAmounts[0] + slotAmounts[1]) * materialAmount
	tempSlider.value = mixingAmount
	#print("amount 0: " + str(slotAmounts[0]))
	#print("amount 1: " + str(slotAmounts[1]))
	#print("mixingAmount is " + str((slotAmounts[0] + slotAmounts[1]) * materialAmount))
	
	match color:
		COLORS.RED:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/REDsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.RED])
		COLORS.ORG:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/ORGsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.ORG])
		COLORS.YEL:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/YELsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.YEL])
		COLORS.GRN:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/GRNsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.GRN])
		COLORS.BLU:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/BLUsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.BLU])
		COLORS.PUR:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/PURsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.PUR])
		COLORS.BLK:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/BLKsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.BLK])
		COLORS.WHT:
			tempSymbol.texture = load("res://assets/GUI/PaintMaking/symbols/WHTsymbol.PNG")
			style.bg_color = Color.hex(hexColors[COLORS.WHT])


func changePhase(phase: PHASE):
	currPhase = phase


func enableKnife():
	currPhase = PHASE.KNIFE
	print("entering knife phase")


func addPaint():
	if(currPhase == PHASE.KNIFE):
		print ("adding paint to inventory")
		gameManager.paintInv[mixingColor] += mixingAmount
		loadPaintInventory(mixingColor)
		currPhase = PHASE.SELECT
		mixingColor = -1
		mixingAmount = 0
		clearSlot(0)
		clearSlot(1)
		updateBottle(mixingColor)


func loadPaintInventoryAll():
	for x: int in range(0,8):
		loadPaintInventory(x)


func loadPaintInventory(color: int):
	var tempNode
	match color:
		COLORS.RED:
			tempNode = paintInventory.get_node("HotbarContainer/RED/REDBottle/REDPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.RED]
		COLORS.ORG:
			tempNode = paintInventory.get_node("HotbarContainer/ORG/ORGBottle/ORGPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.ORG]
		COLORS.YEL:
			tempNode = paintInventory.get_node("HotbarContainer/YEL/YELBottle/YELPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.YEL]
		COLORS.GRN:
			tempNode = paintInventory.get_node("HotbarContainer/GRN/GRNBottle/GRNPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.GRN]
		COLORS.BLU:
			tempNode = paintInventory.get_node("HotbarContainer/BLU/BLUBottle/BLUPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.BLU]
		COLORS.PUR:
			tempNode = paintInventory.get_node("HotbarContainer/PUR/PURBottle/PURPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.PUR]
		COLORS.BLK:
			tempNode = paintInventory.get_node("HotbarContainer/BLK/BLKBottle/BLKPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.BLK]
		COLORS.WHT:
			tempNode = paintInventory.get_node("HotbarContainer/WHT/WHTBottle/WHTPaintSlider")
			tempNode.value = gameManager.paintInv[COLORS.WHT]


# Enables ALL RigidBody colliders in the GUI
func enableColliders():
	$Mortar.get_node("CollisionPolygon2D").set_disabled(false)
	
	for child in bowlMaterials.get_children():
		child.get_node("CollisionShape2D").set_disabled(false)
		child.isActive = true


# Disables ALL RigidBody colliders in the GUI
func disableColliders():
	$Mortar.get_node("CollisionPolygon2D").set_disabled(true)
	
	for child in bowlMaterials.get_children():
		child.setLocalPos()
		child.get_node("CollisionShape2D").set_disabled(true)
		child.isActive = false


func _on_back_btn_pressed() -> void:
	disableColliders()
	inventoryGUI.set_visible(true)
	set_visible(false)
	inventoryGUI.updateAllLabels()
	player.canWalk = true

func _on_palette_knife_btn_pressed() -> void:
	selectTool(TOOLS.KNIFE)
	prevPosition = paletteKnife.position


func _on_glass_muller_btn_pressed() -> void:
	selectTool(TOOLS.MULLER)
	prevPosition = glassMuller.position


func _on_pestle_btn_pressed() -> void:
	selectTool(TOOLS.PESTLE)
	prevPosition = pestle.position


func _on_spoon_btn_pressed() -> void:
	selectTool(TOOLS.SPOON)
	prevPosition = spoon.position


func _on_pipette_btn_pressed() -> void:
	selectTool(TOOLS.PIPETTE)
	prevPosition = pipette.position


func _on_red_box_btn_pressed() -> void:
	addToMortar(COLORS.RED)


func _on_yel_box_btn_pressed() -> void:
	addToMortar(COLORS.YEL)


func _on_blu_box_btn_pressed() -> void:
	addToMortar(COLORS.BLU)


func _on_blk_box_btn_pressed() -> void:
	addToMortar(COLORS.BLK)


func _on_wht_box_btn_pressed() -> void:
	addToMortar(COLORS.WHT)


func _on_slot_0_btn_pressed() -> void:
	if(slots[0] != -1):
		removeFromMortar(slots[0])


func _on_slot_1_btn_pressed() -> void:
	if(slots[1] != -1):
		removeFromMortar(slots[1])
