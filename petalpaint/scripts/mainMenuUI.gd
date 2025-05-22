extends Control

@onready var startBtn = %StartBtn
@onready var optionsBtn = %OptionsBtn
@onready var exitBtn = %ExitBtn
@onready var backBtn = $OptionsGUI/BackBtn

@onready var menuBar = $MenuBar
@onready var options = $OptionsGUI

var cursor = load("res://assets/GUI/cursor_2.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.set_custom_mouse_cursor(cursor)
	
	startBtn.pressed.connect(startBtnPressed)
	optionsBtn.pressed.connect(optionsBtnPressed)
	exitBtn.pressed.connect(exitBtnPressed)
	backBtn.pressed.connect(backBtnPressed)

func startBtnPressed():
	get_tree().change_scene_to_file("res://scenes/exploration.tscn")

func optionsBtnPressed():
	# open options GUI
	menuBar.visible = false;
	options.visible = true;
	
func exitBtnPressed():
	get_tree().quit()

func backBtnPressed():
	options.visible = false;
	menuBar.visible = true
