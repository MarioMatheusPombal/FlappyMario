extends Node2D

@export var pipe_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var pipes : Array
const PIPE_DELAY : int = 100
const PIPE_RANGE : int = 200


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "KWANZAS: " + str(score)
	$Defeat.hide()
	get_tree().call_group("pipes", "queue_free")
	pipes.clear()
	generate_pipes()
	$Mario.reset()

func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $Mario.flying:
						$Mario.flap()
						check_top()

func start_game():
	game_running = true
	$Mario.flying = true
	$Mario.flap()
	$PipeTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED


func _on_pipe_timer_timeout() -> void:
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(mario_hit)
	pipe.score.connect(scored)
	add_child(pipe)
	pipes.append(pipe) 
	
func scored():
	score +=1
	$ScoreLabel.text = "KWANZAS: "+ str(score)

func check_top():
	if $Mario.position.y < 0:
		$Mario.falling = true
		stop_game()

func stop_game():
	$PipeTimer.stop()
	$Mario.flying = false
	game_running = false
	game_over = false
	$Defeat.show()

func mario_hit():
	$Mario.falling = true
	stop_game()



func _on_ground_hit() -> void:
	$Mario.falling = false
	stop_game()


func _on_defeat_restart() -> void:
	new_game()
