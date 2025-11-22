extends Node2D

const CARD_WIDTH = 200
const HAND_Y_POSITION = 950

var player_hand = []
var center_screen_x


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x /2
	
	

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_position()
	else:
		animate_card_to_position(card, card.hand_position)


func update_hand_position():
	for i in range(player_hand.size()):
		#get new card position based on index passed
		var new_postion = Vector2(calculate_card_postion(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_postion
		animate_card_to_position(card, new_postion)
		


func calculate_card_postion(index):
	var x_offset = (player_hand.size() -1) * CARD_WIDTH
	var x_position = center_screen_x + index * CARD_WIDTH - x_offset /2
	return x_position


func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)


func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()
	
