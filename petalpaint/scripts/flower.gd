extends Area2D

enum OBJECTS {RED, ORG, YEL, GRN, BLU, PUR, BLK, WHT, TABLE, EASLE}
@onready var gameManager: Node = %GameManager
@onready var player: Node = %Player
@onready var label: Label = $Label
@onready var paintTableGUI: Control = %PaintTableGUI # this should be refactored
@onready var inventoryGUI: Control = %InventoryGUI
@onready var paintingGUI: Control = %PaintingGUI
@onready var canInteract = false
@export var object: OBJECTS

var rng = RandomNumberGenerator.new()
var from = -4.0
var to = -4.0
var offset = 2.0 # how much the end points two and from can vary
var speed = .001

var timer = 0

var breeze = .002 # .005 = windy, .001 = small breeze


func _ready() -> void:
	if(object != OBJECTS.TABLE && object != OBJECTS.EASLE):
		# apply randomness to the flipping of materials
		var num = rng.randi_range(0,1)
		if(num == 0):
			scale.x = -1


func _process(_delta: float) -> void:
	#timer += delta

	#if(timer >= 4):
		#toggleBreeze()
		#timer = 0		
	
	if(object == OBJECTS.RED || object == OBJECTS.YEL || object == OBJECTS.BLU):
		skew += speed
		#print(skew)
		if(skew > (.06)):
			speed -= breeze
		if(skew < (-.06)):
			speed += breeze
		


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		label.set_visible(true)
		canInteract = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		label.set_visible(false)
		canInteract = false

func _input(_event):
	if(Input.is_action_just_pressed("interact") && canInteract):
		if(object == OBJECTS.TABLE):
			inventoryGUI.set_visible(false)
			player.canWalk = false
			paintTableGUI.set_visible(true)
			paintTableGUI.setValues()
			paintTableGUI.enableColliders()
		elif(object == OBJECTS.EASLE):
			inventoryGUI.set_visible(false)
			player.canWalk = false
			paintingGUI.set_visible(true)
		else: # collect material
			if(gameManager.materialInv[object] < 100):
				gameManager.addMaterial(object)
				queue_free()
			else:
				print("inventory full") # notify the player better ~ pop up


func toggleBreeze():
	if(breeze == 0.002):
		breeze = 0.005
	elif(breeze == 0.005):
		breeze = 0.002
