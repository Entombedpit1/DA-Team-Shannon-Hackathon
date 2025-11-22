extends Node2D

var table_arr:Array[CardResource] # array of all the cards on the table
var ranks_already_on_table:Array[int] # list of ranks already on the table to determine what cards can be played
var open_attacks:Dictionary[CardResource, int] # list of cards defense needs to defend and the card lane
var nums_attack_lanes:int

var draw_pile:Array[CardResource]

var power_suit:StringName;
var attacker:StringName
var defender:StringName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nums_attack_lanes = 0
	table_arr = []
	ranks_already_on_table = []
	

func first_attack(card:CardResource) -> bool:
	var tempArr:Array[CardResource] = [card]
	table_arr.append(tempArr)
	open_attacks[card] = nums_attack_lanes
	nums_attack_lanes += 1
	return true

func attack(card:CardResource) -> bool:
	if ranks_already_on_table.has(card.Rank):
		var tempArr:Array[CardResource] = [card]
		table_arr.append(tempArr)
		open_attacks[card] = nums_attack_lanes
		nums_attack_lanes += 1
		return true
	else:
		return false

func first_defend(attacking_card:CardResource, defending_card:CardResource):
	if (attacking_card.Rank == defending_card.Rank):
		pass
	else:
		defend(attacking_card, defending_card)

func defend(attacking_card:CardResource, defending_card:CardResource) -> bool:
	if (defending_card.Suit == power_suit || defending_card.Suit == attacking_card.Suit):
		if (defending_card.Rank > attacking_card.Rank):
			# REMEMBER TO IMPLEMENT GRAPHICS
			open_attacks.erase(attacking_card)
			table_arr.append(defending_card)
			return true
	return false

func end_turn() -> void:
	if (open_attacks.is_empty()):
		# defender is successful
		pass
