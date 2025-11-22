extends Node2D

var example:int;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	example = 0;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event):
	if event.is_action_pressed("ui_up"):
		example += 1;
	elif event.is_action_pressed("ui_down"):
		example -= 1;
	elif event.is_action_pressed("ui_right"):
		print(example)
	
