extends Node2D

var enemy_scene: PackedScene = preload("res://Enemy.tscn")
var item_scene: PackedScene = preload("res://Item.tscn")

@onready var katamari = $Katamari
@onready var hp_label = $HUD/HPLabel

# 背景生成用の設定
var bg_sprite: Sprite2D

func _ready():
    _generate_background()
    if katamari:
            katamari.hp_changed.connect(_on_player_hp_changed)
            _on_player_hp_changed(katamari.current_hp) # 初期HPを強制表示
func _generate_background():
    # 巨大すぎる領域指定によるGPUの描画制限を回避するため、
    # ParallaxBackground を用いた確実な無限タイリング方式に変更します。
    var texture = load("res://assets/sprites/pasture_background.png")
    
    if texture:
        var pb = ParallaxBackground.new()
        var pl = ParallaxLayer.new()
        
        bg_sprite = Sprite2D.new()
        bg_sprite.name = "BackgroundSprite"
        bg_sprite.texture = texture
        bg_sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
        bg_sprite.region_enabled = true
        
        # GPUの制限に引っかからない安全なサイズ (8000px)
        var region_size = 8000
        bg_sprite.region_rect = Rect2(0, 0, region_size, region_size)
        
        # 模様のサイズ感を調整
        bg_sprite.scale = Vector2(2.0, 2.0)
        
        # Spriteの実際の表示サイズ (8000 * 2.0 = 16000) でループさせる
        pl.motion_mirroring = Vector2(region_size * 2.0, region_size * 2.0)
        
        pl.add_child(bg_sprite)
        pb.add_child(pl)
        
        # 最背面に配置する
        add_child(pb)
        move_child(pb, 0)
    else:
        push_error("背景用テクスチャが見つかりません: res://assets/sprites/pasture_background.png")


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
func _on_player_hp_changed(new_hp):
    var heart_string = ""
    for i in range(new_hp):
        heart_string += "❤️"
    
    if hp_label:
        hp_label.text = "HP: " + heart_string
