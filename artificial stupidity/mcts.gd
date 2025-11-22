extends Node

var sample_gamestate:GameState
func _ready():
	sample_gamestate = GameState.new()
	sample_gamestate.table_arr = []
	sample_gamestate.ranks_already_on_table = []
	sample_gamestate.example = 0
	sample_gamestate.draw_pile = DefaultCards.populate_default_cards()
	sample_gamestate.draw_pile.shuffle()
	
	sample_gamestate.opponent_max_health = GlobalInfo.player_stats.MAX_HEALTH
	sample_gamestate.opponent_curr_health = sample_gamestate.opponent_max_health
	sample_gamestate.is_attacking = false
	sample_gamestate.self_max_health = 100
	sample_gamestate.self_curr_health = sample_gamestate.self_max_health
	for n in 6:
		sample_gamestate.self_hand = sample_gamestate.draw_pile.pop_front()
		sample_gamestate.opponent_hand = sample_gamestate.draw_pile.pop_front()
	sample_gamestate.active_attacks = []
	sample_gamestate.ranks_on_board = []
	sample_gamestate.num_cards_on_board = 0
	sample_gamestate.is_terminal = false
	# First card is selected as Trump suit and removed from draw pile
	sample_gamestate.trump_suit = sample_gamestate.draw_pile.pop_front()

	print("Player health: ", sample_gamestate.player_health)
	print("Power suit: ", sample_gamestate.power_suit)

class GameState:
	var opponent_max_health:int = 100
	var opponent_curr_health:int = 100
	var is_attacking:bool = false
	var self_max_health:int = 100
	var self_curr_health:int = 100
	var draw_pile:Array[CardResource] = []
	var self_hand:Array[CardResource] = []
	var opponent_hand:Array[CardResource] = []
	var active_attacks:Array[CardResource] = []
	var ranks_on_board:Array[int] = []
	var num_cards_on_board:int = 0
	var trump_suit:StringName
	var is_terminal:bool = false
	

func get_legal_actions(game_state:GameState) -> Array[Callable]:
	var call_arr:Array[Callable]
	if (game_state.is_attacking):
		for card in game_state.self_hand:
			if (game_state.ranks_on_board.has(card.Rank)):
				call_arr.push_back(attack.bind(game_state, card))
	else:
		# defender always has option to end turn and accept damage
		call_arr.push_back(end_turn.bind(game_state))
		for atk_card in game_state.active_attacks:
			for card in game_state.self_hand:
				if (card.Suit == game_state.trump_suit || card.Suit == atk_card.Suit):
					if (card.Rank > atk_card.Rank):
						call_arr.push_back(defend.bind(game_state, atk_card, card))
	return call_arr

class MctsNode:
	var total_wins:int
	var visit_count:int
	var parent_node:MctsNode
	var children:Array[MctsNode]
	var game_state:GameState
	
	func max_ucb_child_of_node() -> MctsNode:
		var max_val:float = -INF
		var ret_node:MctsNode
		for child in self.children:
			var e:float = child.upper_conf_bound()
			if (e > max_val):
				max_val = e
				ret_node = child
		return ret_node
		
	func upper_conf_bound() -> float:
		return 1.0 * self.total_wins/self.visit_count + sqrt(2)*sqrt(log(self.parent_node.visit_count)/self.visit_count)


func navigate_to_leaf(node:MctsNode) -> MctsNode:
	var next_node:MctsNode = node
	while (!next_node.children.is_empty()):
		next_node = next_node.max_ucb_child_of_node()
	return next_node

func mountain_cargo_tree_search():
	pass



func attack(game_state:GameState, card:CardResource) -> GameState:
	if game_state.table_arr.is_empty() || game_state.ranks_already_on_table.has(card.Rank):
		game_state.table_arr.append(card)
		game_state.ranks_already_on_table.append(card.Rank)
		game_state.open_attacks.append(card)
		return game_state
	else:
		print("Not allowed! rank not on table")
		return game_state

func defend(game_state:GameState, attacking_card:CardResource, defending_card:CardResource) -> GameState:
	if (defending_card.Suit == game_state.power_suit || defending_card.Suit == attacking_card.Suit):
		if (defending_card.Rank > attacking_card.Rank || attacking_card.Suit != game_state.power_suit):
			# REMEMBER TO IMPLEMENT GRAPHICS
			game_state.open_attacks.erase(attacking_card)
			game_state.table_arr.append(defending_card)
			game_state.ranks_already_on_table.append(defending_card.Rank)
			print("successfully defended")
			return game_state
	print("not allowed! defend better you bozo")
	return game_state

func end_turn(game_state:GameState) -> GameState:
	if (game_state.open_attacks.is_empty()):
		# defender is successful
		print("Defender is defend")
	else:
		for card in game_state.open_attacks:
			if (game_state.is_attacking):
				game_state.opponent_curr_health -= card.Damage
				print("You dealt ", card.Damage, " damage")
			else:
				game_state.self_curr_health -= card.Damage
				print("You were dealt ", card.Damage, " damage")
			game_state.open_attacks.erase(card)
	game_state.table_arr.clear()
	print("You now have ", game_state.player_health, " health")
	if (   game_state.opponent_curr_health <= 0
		|| game_state.self_curr_health <= 0
		|| game_state.draw_pile.is_empty() && (game_state.opponent_hand.is_empty() || game_state.self_hand.is_empty())):
			game_state.is_terminal = true;
	return game_state
