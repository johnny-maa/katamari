extends Area2D

enum ItemType { MAGNET, DASH, CROWN }
@export var item_type: ItemType = ItemType.MAGNET

func _ready():
    add_to_group("item")
    
    # アイテムの種類に応じて色を変更
    match item_type:
        ItemType.MAGNET:
            $Sprite2D.modulate = Color(0.2, 0.5, 1.0) # 青
        ItemType.DASH:
            $Sprite2D.modulate = Color(1.0, 0.2, 0.2) # 赤
        ItemType.CROWN:
            $Sprite2D.modulate = Color(1.0, 0.9, 0.2) # 金色

func pickup():
    # 取得されたら自身を消去
    queue_free()
