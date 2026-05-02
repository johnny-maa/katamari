extends Node

enum GameState { TITLE, PLAYING, RESULT }
var current_state: GameState = GameState.TITLE

var current_size: float = 0.0
var high_score: float = 0.0

const SAVE_PATH = "user://save_data.cfg"

func _ready():
    # 起動時にハイスコアを読み込む
    load_high_score()

func change_to_title():
    current_state = GameState.TITLE
    # タイトルシーンが存在しない場合はエラーになりますが、後で作成します
    get_tree().change_scene_to_file("res://Title.tscn")

func change_to_playing():
    current_state = GameState.PLAYING
    current_size = 0.0 # スコアをリセット
    get_tree().change_scene_to_file("res://Main.tscn")

func change_to_result(final_size: float):
    current_state = GameState.RESULT
    current_size = final_size
    
    # ハイスコアの更新と保存
    if current_size > high_score:
        high_score = current_size
        save_high_score()
        
    # リザルトシーンが存在しない場合はエラーになりますが、後で作成します
    get_tree().change_scene_to_file("res://Result.tscn")

func save_high_score():
    var config = ConfigFile.new()
    config.set_value("score", "high_score", high_score)
    var err = config.save(SAVE_PATH)
    if err != OK:
        push_error("Failed to save high score.")

func load_high_score():
    var config = ConfigFile.new()
    var err = config.load(SAVE_PATH)
    if err == OK:
        high_score = config.get_value("score", "high_score", 0.0)
    else:
        # セーブデータがない、または読み込めない場合は0
        high_score = 0.0
