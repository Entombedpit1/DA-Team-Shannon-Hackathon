extends Node



var player_stats:PlayerStats
func _ready() -> void:
	player_stats = PlayerStats.new()
	player_stats.MAX_HEALTH = 100
	player_stats.MAX_CONSUMABLES = 3
	player_stats.CARD_DECK = DefaultCards.populate_default_cards()
