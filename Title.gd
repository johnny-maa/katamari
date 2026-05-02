extends Control

@onready var high_score_label = $VBoxContainer/HighScoreLabel
@onready var start_button = $VBoxContainer/StartButton

func _ready():
	# ハイスコアの表示
	var hs = GameManager.high_score
	if hs > 0:
		high_score_label.text = "High Score: %d cm" % int(hs)
	else:
		high_score_label.text = "High Score: -- cm"
		
	start_button.pressed.connect(_on_start_pressed)
	
	# 起動時の状態リセット
	GameManager.current_state = GameManager.GameState.TITLE

func _on_start_pressed():
	GameManager.change_to_playing()
