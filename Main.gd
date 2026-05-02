extends Node2D

var enemy_scene: PackedScene = preload("res://Enemy.tscn")
var item_scene: PackedScene = preload("res://Item.tscn")

@onready var katamari = $Katamari

var time_left: float = 120.0 # 2分ウェーブ
var spawn_timer: float = 0.0
var spawn_interval: float = 1.0

var item_timer: float = 0.0
var item_interval: float = 15.0 # 15秒ごとにアイテム

@onready var time_label = $HUD/TimeLabel
@onready var score_label = $HUD/ScoreLabel

func _process(delta):
    if time_label:
        time_label.text = "Time: %d" % int(max(0, time_left))
    if score_label and katamari:
        var size_cm = int(katamari.current_radius * 1.5) # 見た目上のサイズ値
        score_label.text = "Size: %d cm" % size_cm

    if time_left <= 0:
        var final_size = katamari.current_radius * 1.5
        GameManager.change_to_result(final_size)
        set_process(false) # 複数回呼ばれないように処理を停止
        return
        
    time_left -= delta
    spawn_timer -= delta
    item_timer -= delta
    
    if spawn_timer <= 0:
        # 時間経過でスポーン頻度を少し上げる
        spawn_interval = max(0.2, 1.0 - (120.0 - time_left) / 120.0 * 0.8)
        spawn_timer = spawn_interval
        spawn_enemy()
        
    if item_timer <= 0:
        item_timer = item_interval
        spawn_item()

func spawn_enemy():
    var enemy = enemy_scene.instantiate()
    enemy.enemy_type = determine_enemy_type()
    
    var angle = randf() * PI * 2
    var distance = 1000.0 # 画面外
    var spawn_pos = katamari.global_position + Vector2(cos(angle), sin(angle)) * distance
    
    enemy.global_position = spawn_pos
    add_child(enemy)

func determine_enemy_type() -> int:
    var elapsed = 120.0 - time_left
    var rand = randf()
    if elapsed < 30:
        return 0 # CHICK
    elif elapsed < 75:
        # 30~75s: Chick 60%, Rabbit 40%
        return 1 if rand < 0.4 else 0
    else:
        # 75~120s: Chick 30%, Rabbit 40%, Bear 30%
        if rand < 0.3:
            return 2 # BEAR
        elif rand < 0.7:
            return 1 # RABBIT
        else:
            return 0 # CHICK

func spawn_item():
    var item = item_scene.instantiate()
    item.item_type = randi() % 3
    
    # プレイヤーの近く（画面内くらい）にスポーン
    var angle = randf() * PI * 2
    var distance = randf_range(200.0, 500.0)
    var spawn_pos = katamari.global_position + Vector2(cos(angle), sin(angle)) * distance
    item.global_position = spawn_pos
    add_child(item)
