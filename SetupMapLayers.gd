@tool
extends EditorScript

func _run():
    var scene = get_scene()
    if not scene:
        print("エラー: 対象のシーンが開かれていません。Mainシーンを開いてから実行してください。")
        return
        
    # 1. ルートノードの Y-Sort を有効化
    if "y_sort_enabled" in scene:
        scene.y_sort_enabled = true
        print("✅ ルートノードの Y-Sort を有効化しました。")
        
    # 2. GroundLayer (地面用レイヤー、z_index = -1) の生成
    # ※既に存在しない場合のみ追加
    if not scene.has_node("GroundLayer"):
        var ground_layer = TileMapLayer.new()
        ground_layer.name = "GroundLayer"
        ground_layer.z_index = -1
        scene.add_child(ground_layer)
        ground_layer.owner = scene # エディタ上でノードを保存対象にするために必須
        print("✅ GroundLayer を追加しました。")
    else:
        print("⚠️ GroundLayer は既に存在します。")
    
    # 3. ObjectLayer (障害物・立体物用レイヤー、y_sort_enabled = true) の生成
    if not scene.has_node("ObjectLayer"):
        var object_layer = TileMapLayer.new()
        object_layer.name = "ObjectLayer"
        object_layer.y_sort_enabled = true
        scene.add_child(object_layer)
        object_layer.owner = scene
        print("✅ ObjectLayer を追加しました。")
    else:
        print("⚠️ ObjectLayer は既に存在します。")
    
    # 4. プレイヤー (Katamari) の Y-Sort 設定
    var katamari = scene.get_node_or_null("Katamari")
    if katamari:
        if "y_sort_enabled" in katamari:
            katamari.y_sort_enabled = true
            print("✅ Katamari ノードの Y-Sort を有効化しました。")
    else:
        print("⚠️ Katamari ノードが見つかりません。")
        
    print("🎉 マップレイヤー構造の自動構築が完了しました！")
