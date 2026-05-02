extends Area2D

enum EnemyType { CHICK, RABBIT, BEAR }
@export var enemy_type: EnemyType = EnemyType.CHICK

var speed: float = 100.0
var enemy_radius: float = 16.0

var target: Node2D = null
var is_absorbed: bool = false

func _ready():
    add_to_group("enemy")
    target = get_tree().get_first_node_in_group("player")
    setup_enemy()

func setup_enemy():
    match enemy_type:
        EnemyType.CHICK:
            enemy_radius = 16.0
            speed = 120.0
            $Sprite2D.modulate = Color(1.0, 1.0, 0.5) # 黄色
            $Sprite2D.scale = Vector2(0.25, 0.25)
        EnemyType.RABBIT:
            enemy_radius = 32.0
            speed = 90.0
            $Sprite2D.modulate = Color(0.9, 0.9, 0.9) # 白色
            $Sprite2D.scale = Vector2(0.5, 0.5)
        EnemyType.BEAR:
            enemy_radius = 64.0
            speed = 50.0
            $Sprite2D.modulate = Color(0.6, 0.4, 0.2) # 茶色
            $Sprite2D.scale = Vector2(1.0, 1.0)
            
    # 共有リソースの干渉を避けるため独立したShapeを作成
    var shape = CircleShape2D.new()
    shape.radius = enemy_radius
    $CollisionShape2D.shape = shape

func _process(delta):
    if is_absorbed or target == null:
        return
        
    var direction = global_position.direction_to(target.global_position)
    global_position += direction * speed * delta
    
    if direction.x < 0:
        $Sprite2D.flip_h = false
    elif direction.x > 0:
        $Sprite2D.flip_h = true

func disable_enemy():
    is_absorbed = true
    set_process(false)
    $CollisionShape2D.set_deferred("disabled", true)
