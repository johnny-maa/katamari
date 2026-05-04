extends CharacterBody2D
# --- 追加：シグナルと変数 ---
signal hp_changed(new_hp)

var max_hp = 3
var current_hp = 3
var is_invincible = false
var invincibility_timer: float = 0.0
# ------------------------
var base_speed: float = 400.0
var current_speed: float = 400.0

@onready var katamari_sprite = $KatamariSprite
@onready var katamari_collision = $CollisionShape2D
@onready var pusher_sprite = $PusherSprite
@onready var absorb_area = $AbsorbArea
@onready var absorb_collision = $AbsorbArea/CollisionShape2D
@onready var pusher_hitbox = $PusherSprite/PusherHitbox
@onready var camera = $Camera2D

var current_radius: float = 32.0 
var base_radius: float = 32.0

# プレイヤー（押す人）の体力
var has_crown: bool = false
var has_magnet: bool = false
var item_timer: float = 0.0

# 被弾処理
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready():
    add_to_group("player")
    absorb_area.area_entered.connect(_on_absorb_area_entered)
    pusher_hitbox.area_entered.connect(_on_pusher_hitbox_entered)
    pusher_hitbox.body_entered.connect(_on_pusher_hitbox_body_entered) # 障害物判定用
    current_hp = max_hp
    update_size(current_radius)
 # 既存の_ready処理があれば残しつつ、最後に以下を追加
    current_hp = max_hp
    hp_changed.emit(current_hp) # 初期HPをUIに伝える
    
func _physics_process(delta):
    if camera:
        # ズーム倍率は、半径に反比例（大きくなるほど引く）。引きすぎないように平方根を取り、下限を0.4にする
        var target_zoom = clamp(sqrt(base_radius / current_radius), 0.4, 1.0)
        camera.zoom = camera.zoom.lerp(Vector2(target_zoom, target_zoom), delta * 2.0)

    # 無敵時間の処理
    if is_invincible:
        invincibility_timer -= delta
        # 点滅させる
        katamari_sprite.modulate.a = 0.5 if int(invincibility_timer * 10) % 2 == 0 else 1.0
        if invincibility_timer <= 0:
            is_invincible = false
            katamari_sprite.modulate.a = 1.0

    # アイテム効果時間の処理
    if item_timer > 0:
        item_timer -= delta
        if item_timer <= 0:
            reset_items()
            
    # ノックバックの減衰
    if knockback_velocity.length() > 10:
        knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, delta * 5.0)
    else:
        knockback_velocity = Vector2.ZERO

    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    
    if direction != Vector2.ZERO:
        # ノックバック中はノックバックベクトルが優先される
        velocity = direction * current_speed + knockback_velocity
        
        pusher_sprite.position = -direction.normalized() * (current_radius + 24.0) # キャラと球の間に少し距離を空ける
        
        if direction.x < 0:
            pusher_sprite.flip_h = true
        elif direction.x > 0:
            pusher_sprite.flip_h = false
            
        var distance = (direction * current_speed).length() * delta
        var rot_dir = 1 if velocity.x >= 0 else -1
        katamari_sprite.rotation += (distance / current_radius) * rot_dir
    else:
        velocity = knockback_velocity

    move_and_slide()

func _on_absorb_area_entered(area: Area2D):
    if area.is_in_group("item"):
        pickup_item(area)
        return
        
    if area.is_in_group("enemy"):
        var enemy_r = area.enemy_radius
        
        # 吸着可能な場合（自分の方が大きい or 王冠アイテム使用中）
        if current_radius >= enemy_r or has_crown:
            absorb_enemy.call_deferred(area)
        else:
            # 敵の方が大きい場合（被弾）
            if not is_invincible:
                take_damage(area.global_position)

func _on_pusher_hitbox_entered(area: Area2D):
    # 背後（押している人）に敵が触れたら無条件でダメージ
    if area.is_in_group("enemy") and not is_invincible and not has_crown:
        take_damage(area.global_position)

func _on_pusher_hitbox_body_entered(body: Node2D):
    # TileMapLayerの柵やStaticBody2Dなどの障害物・見えない壁にぶつかったときのダメージ処理
    # Player自身(CharacterBody2D)との衝突は無視する
    if body != self and not is_invincible:
        # 壁から弾かれるように、進行方向の逆向きにノックバックベクトルを作るための仮想位置を渡す
        var push_away_pos = global_position + velocity.normalized() * 100.0
        if velocity == Vector2.ZERO:
            push_away_pos = global_position + Vector2(0, 100)
        take_damage(push_away_pos)

func pickup_item(item: Area2D):
    var type = item.item_type
    item.pickup()
    
    reset_items()
    item_timer = 10.0 # 10秒効果
    
    if type == 0: # MAGNET
        has_magnet = true
        update_size(current_radius) # 吸着範囲の再計算
    elif type == 1: # DASH
        current_speed = base_speed * 2.0
    elif type == 2: # CROWN
        has_crown = true
        katamari_sprite.modulate = Color(1.0, 0.9, 0.2) # 王冠中は少し黄色く発光

func reset_items():
    has_magnet = false
    has_crown = false
    current_speed = base_speed
    katamari_sprite.modulate = Color.WHITE
    update_size(current_radius)

func take_damage(enemy_pos: Vector2):
    # 1. 無敵時間セット
    is_invincible = true
    invincibility_timer = 1.0
    
    # 2. HP減少とゲームオーバー判定
    current_hp -= 1
    hp_changed.emit(current_hp)
    if current_hp <= 0:
        var final_size = current_radius * 1.5
        GameManager.change_to_result(final_size)
        return
    
    # 3. ノックバック
    var dir = enemy_pos.direction_to(global_position)
    if dir == Vector2.ZERO:
        dir = Vector2.UP # 位置が完全に重なっている場合のフェイルセーフ
    knockback_velocity = dir * 800.0 # 強く弾く
    
    # 4. サイズ減少 (面積を10%減らす)
    var current_area = current_radius * current_radius
    var new_area = current_area * 0.9
    current_radius = max(base_radius, sqrt(new_area))
    update_size(current_radius)
    
    # 4. くっついている動物をいくつか落とす
    drop_animals(3)

func drop_animals(count: int):
    var children = katamari_sprite.get_children()
    var dropped = 0
    for child in children:
        if child.is_in_group("enemy") and dropped < count:
            child.queue_free()
            dropped += 1

func absorb_enemy(enemy: Area2D):
    enemy.disable_enemy()
    enemy.reparent(katamari_sprite)
    
    var r = current_radius
    var r_o = enemy.enemy_radius
    
    # 成長鈍化（大きくなるほど吸収効率が下がる。最小10%まで）
    var efficiency = clamp(base_radius / r, 0.1, 1.0)
    
    # ★ここで全体の成長スピードを調整！ 0.5 なら今の半分のペースで大きくなります
    var growth_speed = 0.5 
    var added_area = (r_o * r_o) * efficiency * growth_speed
    
    current_radius = sqrt(r * r + added_area)
    
    update_size(current_radius)	
    # 吸収時のヒットストップ演出
    apply_hit_stop(0.1, 0.05)

func update_size(new_radius: float):
    var scale_factor = new_radius / base_radius
    katamari_sprite.scale = Vector2(scale_factor, scale_factor)
    
    katamari_collision.shape.radius = new_radius
    
    # 磁力アイテム効果なら吸着判定を3倍
    var absorb_multiplier = 3.0 if has_magnet else 1.0
    absorb_collision.shape.radius = (new_radius + 5.0) * absorb_multiplier

func apply_hit_stop(target_time_scale: float, duration: float):
    Engine.time_scale = target_time_scale
    # ignore_time_scaleをtrueにして、タイムスケール低下中でも現実時間で正しく復帰させる
    await get_tree().create_timer(duration, true, false, true).timeout
    Engine.time_scale = 1.0



   
