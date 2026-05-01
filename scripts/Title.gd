extends Control

@onready var new_game_button: Button = $CenterContainer/VBox/NewGameButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)

func _on_new_game_pressed() -> void:
	GameState.initialize_regions()
	get_tree().change_scene_to_file("res://scenes/CastleHub.tscn")
