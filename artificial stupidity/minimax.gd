extends Node

class MiniMaxNode:
	var draw_pile:Array[CardResource] = []

class GameState:
	var draw_pile:Array[CardResource]
	var self_hand:Array[CardResource]


func miniMax(game_state:GameState):
	pass
