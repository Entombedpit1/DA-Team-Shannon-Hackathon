extends Node2D

const CARD_SCENE_PATH = "res://tutorial/Card.tscn"


@onready var sprite := $CardImage

var card_data: Dictionary

func set_card(data: Dictionary):
	card_data = data
	sprite.texture = load(data.image)
	
	
	


var player_deck = ["Hearts_card_01", "Hearts_card_02", "Hearts_card_03", 
"Hearts_card_04", "Hearts_card_05", "Hearts_card_06"]
var data_base_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	data_base_reference = preload("res://tutorial/CardDatabase.gd")



func draw_card():
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	#if last card drawn disables deck
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
<<<<<<< HEAD
=======
	$RichTextLabel.text = str(player_deck.size())
>>>>>>> 436eac07172b8ddaca9389a6e34e61a2f52b15af
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	var card_image_path = str("res://tutorial/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	$"../PlayerHand".add_card_to_hand(new_card)
