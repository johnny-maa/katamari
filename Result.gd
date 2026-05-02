extends Control

@onready var result_label = $VBoxContainer/ResultLabel
@onready var score_label = $VBoxContainer/ScoreLabel
@onready var high_score_label = $VBoxContainer/HighScoreLabel
@onready var retry_button = $VBoxContainer/RetryButton
@onready var title_button = $VBoxContainer/TitleButton

func _ready():
    var current = GameManager.current_size
    var hs = GameManager.high_score
    
    score_label.text = "Result Size: %d cm" % int(current)
    high_score_label.text = "High Score: %d cm" % int(hs)
    
    if current >= hs and current > 0:
        result_label.text = "NEW RECORD!!"
        result_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
    else:
        result_label.text = "TIME UP!"
        
    retry_button.pressed.connect(_on_retry_pressed)
    title_button.pressed.connect(_on_title_pressed)

func _on_retry_pressed():
    GameManager.change_to_playing()

func _on_title_pressed():
    GameManager.change_to_title()
