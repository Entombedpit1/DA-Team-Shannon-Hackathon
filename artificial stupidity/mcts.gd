extends Node

const MAX_HAND_SIZE:int = 6
var sample_gamestate:GameState
func _ready():
	sample_gamestate = GameState.new()
	sample_gamestate.discard_pile = []
	sample_gamestate.ranks_on_board = []
	sample_gamestate.draw_pile = DefaultCards.populate_default_cards()
	sample_gamestate.draw_pile.shuffle()
	
	sample_gamestate.player_max_health = GlobalInfo.player_stats.MAX_HEALTH
	sample_gamestate.player_curr_health = sample_gamestate.player_max_health
	sample_gamestate.computer_is_attacking = false
	sample_gamestate.computer_max_health = 100
	sample_gamestate.computer_curr_health = sample_gamestate.computer_max_health
	for n in MAX_HAND_SIZE:
		sample_gamestate.computer_hand.append(sample_gamestate.draw_pile.pop_back())
		sample_gamestate.player_hand.append(sample_gamestate.draw_pile.pop_back())
	sample_gamestate.active_attacks = []
	sample_gamestate.ranks_on_board = []
	sample_gamestate.is_terminal = false
	# First card is selected as Trump suit and removed from draw pile
	sample_gamestate.trump_suit = sample_gamestate.draw_pile.pop_back().Suit

	print("Player health: ", sample_gamestate.player_curr_health)
	print("Trump suit: ", sample_gamestate.trump_suit)
	print("Self_hand")
	for card in sample_gamestate.computer_hand:
		print(card.Rank, " ", card.Suit)
	print("Other_hand")
	for card in sample_gamestate.player_hand:
		print(card.Rank, " ", card.Suit)
	sample_gamestate = attack(sample_gamestate, sample_gamestate.player_hand[0])
	print("##########################################")
	print(mountain_cargo_tree_search(sample_gamestate, 1000))
	print("##########################################")

class GameState:
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
		

func get_legal_actions(game_state:GameState) -> Array[Callable]:
	var call_arr:Array[Callable]
	if (!game_state.ranks_on_board.is_empty()):
		call_arr.push_back(end_turn.bind(game_state))
	else:
		if (game_state.computer_is_attacking):
			for card in game_state.computer_hand:
				call_arr.push_back(attack.bind(game_state, card))
		else:
			for card in game_state.player_hand:
				call_arr.push_back(attack.bind(game_state, card))
	if (game_state.computer_is_attacking):
		for card in game_state.computer_hand:
			print(game_state.computer_hand.size(), game_state.computer_hand[game_state.computer_hand.size() - 1])
			if (game_state.ranks_on_board.has(card.Rank)):
				call_arr.push_back(attack.bind(game_state, card))
		for atk_card in game_state.active_attacks:
			for card in game_state.player_hand:
				if (card.Suit == atk_card.Suit):
					if (card.Rank > atk_card.Rank):
						call_arr.push_back(defend.bind(game_state, atk_card, card))
				elif (card.Suit == game_state.trump_suit):
					call_arr.push_back(defend.bind(game_state, atk_card, card))
					
	else:
		# computer is attacking
		print("size: ",game_state.computer_hand.size())
		for card in game_state.computer_hand:
			print(card.Rank, card.Suit)
			if (game_state.ranks_on_board.has(card.Rank)):
				call_arr.push_back(attack.bind(game_state, card))
		# player is defending
		for atk_card in game_state.active_attacks:
			for card in game_state.computer_hand:
				if (card.Suit == atk_card.Suit):
					if (card.Rank > atk_card.Rank):
						call_arr.push_back(defend.bind(game_state, atk_card, card))
				elif (card.Suit == game_state.trump_suit):
					call_arr.push_back(defend.bind(game_state, atk_card, card))
	return call_arr

class MctsNode:
	var total_wins:int = 0
	var visit_count:int = 0
	var parent_node:MctsNode
	var children:Array[MctsNode]
	var available_actions:Array[Callable]
	var action_parent_took:Callable
	var game_state:GameState
	
	func max_ucb_child_of_node() -> MctsNode:
		var max_val:float = -INF
		var ret_node:MctsNode = self
		for child in self.children:
			var e:float = child.upper_conf_bound()
			if (e > max_val):
				max_val = e
				ret_node = child
		return ret_node
		
	func upper_conf_bound() -> float:
		return 1.0 * self.total_wins/self.visit_count + sqrt(2)*sqrt(log(self.parent_node.visit_count)/self.visit_count)
	
	func find_highest_avg_reward_action() -> Callable:
		var highest_child:MctsNode = self.children[0]
		var highest_avg_reward:float = 1.0*highest_child.total_wins/highest_child.visit_count
		for child in self.children:
			var curr_avg:float = (1.0*child.total_wins/child.visit_count)
			if (curr_avg > highest_avg_reward):
				highest_child = child
				highest_avg_reward = curr_avg
		print("highest_avg_reward", highest_avg_reward)
		return highest_child.action_parent_took

func navigate_to_leaf(node:MctsNode) -> MctsNode:
	var next_node:MctsNode = node
	while (!next_node.children.is_empty()):
		next_node = next_node.max_ucb_child_of_node()
	return next_node

func mountain_cargo_tree_search(root_state:GameState, iteration_limit:int) -> Callable:
	var root_node:MctsNode = MctsNode.new()
	root_node.game_state = root_state
	root_node.parent_node = null
	root_node.available_actions = get_legal_actions(root_node.game_state)
	print("FOR THIS SCENARIO")
	#root_node.game_state.print_game_state()
	print("available acitons:::::::")
	print(root_node.available_actions)
	var i:int = 0
	while (i < iteration_limit):
		var leaf_node:MctsNode = MctsNode.new()
		leaf_node.parent_node = root_node
		var available_actions:Array[Callable]
		var action_parent_took:Callable
		var game_state:GameState
		var score_result:int
		while (leaf_node.available_actions.is_empty()):
			leaf_node = leaf_node.max_ucb_child_of_node()
		if (!leaf_node.game_state.is_terminal):
			leaf_node = mcts_expand(leaf_node)
			score_result = simulate_node_until_end(leaf_node)
		else:
			score_result = leaf_node.game_state.result_of_computer
		leaf_node.visit_count += 1
		leaf_node.total_wins += score_result
		while (leaf_node.parent_node != null):
			leaf_node = leaf_node.parent_node
			leaf_node.visit_count += 1
			leaf_node.total_wins += score_result
		i += 1
	return new_node.find_highest_avg_reward_action()

func mcts_expand(node:MctsNode) -> MctsNode:
	
	var new_node:MctsNode = MctsNode.new()
	var temp_action:Callable = node.available_actions.pick_random()
	node.available_actions.erase(temp_action)
	new_node.action_parent_took = temp_action
	new_node.game_state = temp_action.call()
	new_node.parent_node = node
	new_node.available_actions = get_legal_actions(new_node.game_state)
	node.children.append(new_node)
	return new_node


func simulate_node_until_end(node:MctsNode) -> int:
	var game_state:GameState = node.game_state
	var sim_state:GameState = node.game_state
	while (sim_state.is_terminal == false):
		print("Available actions:-----------")
		print(get_legal_actions(sim_state))
		print("drawpilesize: ",sim_state.draw_pile.size())
		sim_state = get_legal_actions(sim_state).pick_random().call()
		
	print("Terminated")
	#sim_state.print_game_state()
	print(sim_state.result_of_computer)
	return sim_state.result_of_computer




func attack(game_state:GameState, card:CardResource) -> GameState:
	if game_state.table_arr.is_empty() || game_state.ranks_on_board.has(card.Rank):
		game_state.ranks_on_board.append(card.Rank)
		game_state.active_attacks.append(card)
		if (game_state.computer_is_attacking):
			game_state.computer_hand.erase(card)
		else:
			game_state.player_hand.erase(card)
		return game_state
	else:
		print("Not allowed! rank not on table")
		return game_state

func defend(game_state:GameState, attacking_card:CardResource, defending_card:CardResource) -> GameState:
	if (defending_card.Suit == game_state.trump_suit || defending_card.Suit == attacking_card.Suit):
		if (defending_card.Rank > attacking_card.Rank || attacking_card.Suit != game_state.trump_suit):
			# REMEMBER TO IMPLEMENT GRAPHICS
			game_state.active_attacks.erase(attacking_card)
			game_state.table_arr.append(defending_card)
			game_state.table_arr.append(attacking_card)
			game_state.ranks_on_board.append(defending_card.Rank)
			
			if (game_state.computer_is_attacking): # remove card from respective hand
				game_state.player_hand.erase(defending_card)
			else:
				game_state.computer_hand.erase(defending_card)
			print("successfully defended")
			return game_state
	print("not allowed! defend better you bozo")
	return game_state

func end_turn(game_state:GameState) -> GameState:
	print("END TURN, DAMAGE CALC")
	#game_state.print_game_state()
	if (game_state.active_attacks.is_empty()):
		# defender is successful
		print("Defender is defend")
	else:
		for card in game_state.active_attacks:
			if (game_state.computer_is_attacking):
				game_state.player_curr_health -= card.Damage
				print("Computer dealt ", card.Damage, " damage")
			else:
				game_state.computer_curr_health -= card.Damage
				print("Player dealt ", card.Damage, " damage")
			game_state.discard_pile.append(card)
		game_state.active_attacks.clear()
	print("Player has ", game_state.player_curr_health, " health")
	print("Computer has ", game_state.computer_curr_health, " health")
	for card in game_state.table_arr:
		game_state.discard_pile.append(card)
	game_state.table_arr.clear() # clear inactive cards (not actively attacking)
	
	game_state.ranks_on_board.clear() # clear board
	
	while ((game_state.player_hand.size() < MAX_HAND_SIZE || game_state.computer_hand.size() < MAX_HAND_SIZE) && game_state.draw_pile.size() > 0):
		if game_state.player_hand.size() < MAX_HAND_SIZE:
			game_state.player_hand.append(game_state.draw_pile.pop_back())
		if game_state.computer_hand.size() < MAX_HAND_SIZE:
			game_state.computer_hand.append(game_state.draw_pile.pop_back())
	# terminal conditions
	if (game_state.player_curr_health <= 0):
		game_state.result_of_computer = 1;
		game_state.is_terminal = true;
	elif (game_state.computer_curr_health <= 0):
		game_state.result_of_computer = -1;
		game_state.is_terminal = true;
	elif (game_state.draw_pile.is_empty() && (game_state.player_hand.is_empty() || game_state.computer_hand.is_empty())):
		game_state.result_of_computer = -1;
		game_state.is_terminal = true;
	game_state.computer_is_attacking = !game_state.computer_is_attacking
	print("ENDING TURN ~~~~~~~")
	#game_state.print_game_state()
	print("TURN ENDED ~~~~~~~")
	return game_state

#func simulate_next_step_rand(game_state:GameState) -> GameState:
	#if (game_state.computer_is_attacking):
		
