extends Node2D

var table_arr:Array[CardResource] # array of all the cards on the table
var ranks_already_on_table:Array[int] # list of ranks already on the table to determine what cards can be played
var open_attacks:Array[CardResource] # list of cards defense needs to defend and the card lane
var nums_attack_lanes:int

var DEFAULT_DECK:Dictionary[int,CardResource] 


var draw_pile:Array[CardResource]

var power_suit:StringName;

var attacker:StringName
var defender:StringName

var example:int;

func _input(event):
	if event.is_action_pressed("ui_up"):
		example += 1;
		if example > 51:
			example = 0
		print(DEFAULT_DECK[example].Rank, " ", DEFAULT_DECK[example].Suit)
	elif event.is_action_pressed("ui_down"):
		example -= 1;
		if example < 0:
			example = 51
		print(DEFAULT_DECK[example].Rank, " ", DEFAULT_DECK[example].Suit)
	elif event.is_action_pressed("ui_right"):
		attack(DEFAULT_DECK[example])
		for card in table_arr:
			print(card.Suit, card.Rank)
		print("open attacks: ")
		for card in open_attacks:
			print(card.Suit, card.Rank)
		print("")
	elif event.is_action_pressed("ui_left"):
		if !open_attacks.is_empty():
			defend(open_attacks[0], DEFAULT_DECK[example])
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var i:int = randi_range(0, 3)
	power_suit = DefaultCards.SUIT_NAMES[i]
	nums_attack_lanes = 0
	table_arr = []
	ranks_already_on_table = []
	example = 0
	DEFAULT_DECK = DefaultCards.populate_default_cards()
	print("Power suit: ", power_suit)



func attack(card:CardResource) -> bool:
	if table_arr.is_empty() || ranks_already_on_table.has(card.Rank):
		table_arr.append(card)
		ranks_already_on_table.append(card.Rank)
		open_attacks.append(card)
		nums_attack_lanes += 1
		return true
	else:
		print("Not allowed! rank not on table")
		return false

func first_defend(attacking_card:CardResource, defending_card:CardResource):
	if (attacking_card.Rank == defending_card.Rank):
		pass
	else:
		defend(attacking_card, defending_card)

func defend(attacking_card:CardResource, defending_card:CardResource) -> bool:
	if (defending_card.Suit == power_suit || defending_card.Suit == attacking_card.Suit):
		if (defending_card.Rank > attacking_card.Rank || attacking_card.Suit != power_suit):
			# REMEMBER TO IMPLEMENT GRAPHICS
			open_attacks.erase(attacking_card)
			table_arr.append(defending_card)
			print("successfully defended")
			return true
	print("not allowed! defend better you bozo")
	return false

func end_turn() -> void:
	if (open_attacks.is_empty()):
		# defender is successful
		print("Defender is defend")
	else:
		print("whoopsie u ded")
