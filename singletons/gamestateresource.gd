class_name GameState
extends Node2D
var player_max_health:int = 100
var player_curr_health:int = 100
var computer_is_attacking:bool = false
var computer_max_health:int = 100
var computer_curr_health:int = 100
var draw_pile:Array[CardResource] = []
var computer_hand:Array[CardResource] = []
var player_hand:Array[CardResource] = []
var table_arr:Array[CardResource] = []
var discard_pile:Array[CardResource] = []
var active_attacks:Array[CardResource] = []
var ranks_on_board:Array[int] = []
var trump_suit:StringName
var is_terminal:bool = false
var result_of_computer:int = 0

func print_draw_pile() -> void:
	print("Printing draw pile...")
	var i:int = 0
	for card in self.draw_pile:
		print(card.Rank, " ", card.Suit, " dmg: ", card.Damage)
		i += 1
		
	print("There are ", i, " cards in the draw pile")



func print_game_state() -> void:
	print_draw_pile()
	print("Now: node state")
	print("~~~~~~~~~~ computer hand~ ~~~~~~~~~~~~")
	for card in self.computer_hand:
		print(card.Rank, " ", card.Suit)
	print("~~~~~~~~~~ player hand~ ~~~~~~~~~~~~")
	for card in self.player_hand:
		print(card.Rank, " ", card.Suit)
	print("~~~~~~~~~~ tablearr pile..~~~~~~~~~.")
	for card in self.table_arr:
		print(card.Rank, " ", card.Suit)
	print("~~~~~~~~~~ discard_pile pile..~~~~~~~~~.")
	for card in self.discard_pile:
		print(card.Rank, " ", card.Suit)
	print("~~~~~~~~~~ active_attacks pile..~~~~~~~~~.")
	for card in self.active_attacks:
		print(card.Rank, " ", card.Suit)
	print("~~~~~~~~~~ ranks_on_board pile..~~~~~~~~~.")
	for rank in self.ranks_on_board:
		print("Rank ", rank)
	print("Player has ", self.player_curr_health, " health")
	print("Computer has ", self.computer_curr_health, " health")
	print("IS computer attacking?? ", self.computer_is_attacking)
	
