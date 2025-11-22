extends Node2D

const CARD_SCENE_PATH = "res://tutorial/Card.tscn"

var player_deck = ["Hearts_card_01", "Hearts_card_02", "Hearts_card_03", 
"Hearts_card_04", "Hearts_card_05", "Hearts_card_06"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func draw_card():
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	#if last card drawn disables deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
