extends Node2D


const MAX_HAND_SIZE:int = 6
var game_state:GameState

var power_suit:StringName;

var table_arr:Array[CardResource] # array of all the cards on the table
var ranks_already_on_table:Array[int] # list of ranks already on the table to determine what cards can be played
var open_attacks:Array[CardResource] # list of cards defense needs to defend and the card lane

var draw_pile:Array[CardResource]

var player_1_hand:Array[CardResource]


var attacker:StringName
var player_health:int
var computer_health:int

var defender:StringName

var example:int;

func _input(event):
	if event.is_action_pressed("ui_up"):
		example += 1;
		if example > 51:
			example = 0
		print(game_state.draw_pile[example].Rank, " ", game_state.draw_pile[example].Suit)
	elif event.is_action_pressed("ui_down"):
		example -= 1;
		if example < 0:
			example = 51
		print(game_state.draw_pile[example].Rank, " ", game_state.draw_pile[example].Suit)
	elif event.is_action_pressed("ui_right"):
		attack(game_state.draw_pile[example])
		for card in table_arr:
			print(card.Suit, card.Rank)
		print("open attacks: ")
		for card in open_attacks:
			print(card.Suit, card.Rank, " ", card.Damage)
		print("")
	elif event.is_action_pressed("ui_left"):
		if !open_attacks.is_empty():
			defend(open_attacks[0], draw_pile[example])
	elif event.is_action_pressed("ui_accept"):
		end_turn()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_state = GameState.new()
	game_state.discard_pile = []
	game_state.ranks_on_board = []
	game_state.draw_pile = DefaultCards.populate_default_cards()
	game_state.draw_pile.shuffle()
	
	game_state.player_max_health = GlobalInfo.player_stats.MAX_HEALTH
	game_state.player_curr_health = game_state.player_max_health
	game_state.computer_is_attacking = false
	game_state.computer_max_health = 100
	game_state.computer_curr_health = game_state.computer_max_health
	for n in MAX_HAND_SIZE:
		var temp_res = game_state.draw_pile.pop_back()
		game_state.computer_hand.append(temp_res)
		game_state.player_hand.append(game_state.draw_pile.pop_back())
	game_state.active_attacks = []
	game_state.ranks_on_board = []
	game_state.is_terminal = false
	# First card is selected as Trump suit and removed from draw pile
	var trump_card = game_state.draw_pile.pop_back()
	if trump_card != null:
		game_state.trump_suit = trump_card.Suit
	
	
	attacker = &"Player"
	player_health = GlobalInfo.player_stats.MAX_HEALTH
	print("Player health: ", player_health)


	defender = &"Computer"
	print("Power suit: ", power_suit)



func attack(card:CardResource) -> bool:
	if table_arr.is_empty() || ranks_already_on_table.has(card.Rank):
		table_arr.append(card)
		ranks_already_on_table.append(card.Rank)
		open_attacks.append(card)
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
			ranks_already_on_table.append(defending_card.Rank)
			print("successfully defended")
			return true
	print("not allowed! defend better you bozo")
	return false

func end_turn() -> void:
	if (open_attacks.is_empty()):
		# defender is successful
		print("Defender is defend")
	else:
		for card in open_attacks:
			player_health -= card.Damage
			print("You took ", card.Damage, " damage")
			open_attacks.erase(card)
	table_arr.clear()
	print("You now have ", player_health, " health")
