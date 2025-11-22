extends Node2D

const CARD_SCENE_PATH = "res://tutorial/Card.tscn"

var player_deck = ["Hearts_card_01", "Hearts_card_02", "Hearts_card_03", 
"Hearts_card_04", "Hearts_card_05", "Hearts_card_06", "H7","H8","H9"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck = DefaultCards.populate_default_cards()
	


func draw_card():
	var card_drawn = player_deck.pop_back()
	
	#if last card drawn disables deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	
	print("draw card")
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.card_res = card_drawn
	print(new_card.card_res.Rank)
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
