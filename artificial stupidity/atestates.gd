extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var temp:Array[int] = [1, 2, 3]
	for n in temp.size():
		print(n)
	print(temp)
