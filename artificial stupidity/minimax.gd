extends Node

class MiniMaxNode:
	var draw_pile:Array[CardResource] = []

class GameState:
	var draw_pile:Array[CardResource]
	var self_hand:Array[CardResource]


<<<<<<< HEAD
func mini_max(game_state:GameState, alpha:int, beta:int, depth:int, isMaximPlayer:bool) -> int:
	if (game_state.opponent_curr_health <= 0 || game_state.self_curr_health <= 0):
		return evaluate_game_state(game_state);
	elif (depth == 0 || game_state.opponent_hand.size() <= 0 || game_state.self_hand.size() <= 0):
		# implement MCTS if we have time
		pass
	
	if (isMaximPlayer):
		var max_eval:int = -1000000
		for branch in find_possible_positions(game_state):
			var eval:int = mini_max(branch, alpha, beta, depth - 1, !isMaximPlayer)
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if (beta <= alpha):
				break
		return max_eval
	return false

func find_possible_positions(game_state:GameState) -> Array[GameState]:
	var ret_states:Array[GameState];
	if (game_state.is_attacking):
		for card in game_state.self_hand:
			if (game_state.ranks_on_board.has(card.Rank)):
				var temp:GameState = game_state
				temp.self_hand.erase(card)
				ret_states.append(temp)
	
	return ret_states

# finds all possible positions in a fixed attacker/defender cycle (attacker / defender doesn't change)
func find_possible_pos_cycle(game_state:GameState) -> Array[GameState]:
	var ret_states:Array[GameState]

	# if my guy just gives up
	var new_game_state:GameState = game_state
	if (new_game_state.is_attacking): 
		for card in new_game_state.active_attacks:
			new_game_state.opponent_curr_health -= card.Damage;
	else:
		for card in new_game_state.active_attacks:
			new_game_state.self_curr_health -= card.Damage
	new_game_state.is_attacking = !new_game_state.is_attacking
	for n in range(new_game_state.self_hand.size(), 6):
		new_game_state.draw_pile.pop_back()
	new_game_state.active_attacks.clear()
	new_game_state.ranks_on_board.clear()
	new_game_state.num_cards_on_board = 0
	ret_states.append(new_game_state)
	
	
	return ret_states

func evaluate_game_state(game_state:GameState) -> int:
	if (game_state.self_curr_health <= 0):
		return -10000;
	elif (game_state.opponent_curr_health <= 0):
		return 10000;
	elif (game_state.draw_pile.is_empty() && game_state.opponent_hand.is_empty()):
		return -10000;
	var card_heuristic_values:Array[int] # how much each card is "worth" in terms of winning chances by rank
	var self_hand_value:int = 0; # how much the current hand is evaluated to be "worth" in terms of winning chances
	var added_trump_val:int = 100; # how much value is added if a card is the trump suit
	if (game_state.draw_pile.size() > 26):
		# searchable by rank (2 is index 2, ace is index 14, etc.)
		#                                2    3    4    5    6    7  8  9  10   J   Q   K   A
		card_heuristic_values = [0, 0, -50, -40, -30, -20, -15, -10, 0, 5, 30, 50, 100, 300, 500]
	elif (game_state.draw_pile.size() > 13):
		#                                2    3    4    5    6    7    8   9   10  J  Q   K   A
		card_heuristic_values = [0, 0, -75, -65, -55, -45, -35, -25, -15, -10, -5, 0, 5, 75, 150]
		added_trump_val = 50
	else:
		#                                2    3    4    5    6    7    8   9   10  J  Q   K   A
		card_heuristic_values = [0, 0, -100, -65, -55, -45, -35, -25, -15, -10, -5, 0, 5, 10, 15]
		added_trump_val = 10
	for card in game_state.self_hand:
		self_hand_value += card_heuristic_values[card.Rank]
		if (card.Suit == game_state.trump_suit):
			self_hand_value += added_trump_val
	
	var opp_hand_value:int = 0; # subtract opponent's expected value
	if (game_state.self_hand.size() < 6 || game_state.opponent_hand.size() < 6 ):
		var temp_sum:int = 0;
		for card in game_state.draw_pile:
			temp_sum += card_heuristic_values[card.Rank]
		temp_sum /= game_state.draw_pile.size() # weighted sum of card values in draw pile
		self_hand_value += (6 - game_state.self_hand.size()) * temp_sum; # multiply num of free card slots by weighted sum
		opp_hand_value += (6 - game_state.opponent_hand.size()) * temp_sum;
	var opp_missing_health_val:int = 100 * (game_state.opponent_max_health - game_state.opponent_curr_health)
	var self_missing_health_val:int = -100 * (game_state.self_max_health - game_state.self_curr_health)
	
	return self_hand_value + opp_missing_health_val + self_missing_health_val - opp_hand_value
=======
func miniMax(game_state:GameState):
	pass
>>>>>>> parent of 22be05d (Merge branch 'master' of https://github.com/Entombedpit1/DA-Team-Shannon-Hackathon)
