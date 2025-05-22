extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var speed = 360  # speed in pixels/sec
var right = false
var up = false
var vertical = true # handles which idle to play
var canWalk = true

func _process(_delta):
	if(canWalk != true):
		return
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
	
	# cmd-k to comment and uncomment chunks
	# walk animations
	if Input.is_action_pressed("ui_right"):
		right = true;
		vertical = false;
		animated_sprite.play("walk right")
		
	elif Input.is_action_pressed("ui_left"):
		right = false;
		vertical = false;
		animated_sprite.play("walk left")
		
	elif Input.is_action_pressed("ui_down"):
		up = false;
		vertical = true;
		animated_sprite.play("walk down")
		
	elif Input.is_action_pressed("ui_up"):
		up = true;
		vertical = true;
		animated_sprite.play("walk up")
		
	
		
	# idle animations
	if direction.length() == 0:
		if up == false && vertical == true:
			animated_sprite.play("idle down")
		elif up == true && vertical == true:
			animated_sprite.play("idle up")
		elif right == false && vertical == false:
			animated_sprite.play("idle left")
		elif right == true && vertical == false:
			animated_sprite.play("idle right")
	
