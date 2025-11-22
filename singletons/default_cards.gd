extends Node

var SUIT_NAMES:Array[StringName] = [
	&"Diamonds",
	&"Clubs",
	&"Hearts",
	&"Spades",
	&"Wild"
	]
# default deck

func populate_default_cards() -> Array[CardResource]:
	var DEFAULT_DECK:Array[CardResource]
	for card_num in 52:
		DEFAULT_DECK.append(CardResource.new())
	
	# populates default deck with all 52 cards in a standard deck
	var i:int = 0;
	for suit in 4:
		for rank in range(2,15):
			DEFAULT_DECK[i].Suit = SUIT_NAMES[suit]
			DEFAULT_DECK[i].Rank = rank
			# damage equal to rank (face cards are 10, aces are 11)
			DEFAULT_DECK[i].Damage = 11 if (rank == 14) else min(rank, 10)
			# same thing for defence
			DEFAULT_DECK[i].Defence = 11 if (rank == 14) else min(rank, 10)
			i = i + 1
	print(i)
	return DEFAULT_DECK
