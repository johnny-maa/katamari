@tool
extends EditorScript

func _run():
	print("--- 自動セットアップ開始 ---")
	
	# ----------------------------------------------------
	# 1. TileSet の自動構築（当たり判定の付与）
	# ----------------------------------------------------
	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(16, 16)
	
	# 物理レイヤーを追加 (Physics Layer 0)
	tile_set.add_physics_layer(0)
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)
	
	var atlas_source = TileSetAtlasSource.new()
	var tex = load("res://assets/sprites/tilesheet.png")
	
	if tex:
		atlas_source.texture = tex
		atlas_source.texture_region_size = Vector2i(16, 16)
		
		# 当たり判定をつけるタイルの座標リスト（木や柵など）
		# ※仮にアトラス画像の右側の要素 (x=2, 3) を障害物とみなします
		var collision_coords = [
			Vector2i(2, 0), Vector2i(3, 0), 
			Vector2i(2, 1), Vector2i(3, 1)
		]
		
		# 画像サイズからタイル数を計算して全タイルを登録
		var cols = tex.get_width() / 16
		var rows = tex.get_height() / 16
		for x in range(cols):
			for y in range(rows):
				var coord = Vector2i(x, y)
				atlas_source.create_tile(coord)
				
				# 指定したタイルに16x16ピクセル全体を覆う四角形の当たり判定を追加
				if coord in collision_coords:
					var tile_data = atlas_source.get_tile_data(coord, 0)
					if tile_data:
						tile_data.add_collision_polygon(0)
						var polygon = PackedVector2Array([
							Vector2(-8, -8), Vector2(8, -8),
							Vector2(8, 8), Vector2(-8, 8)
						])
						tile_data.set_collision_polygon_points(0, 0, polygon)
		
		tile_set.add_source(atlas_source, 0)
		
		# リソースとして保存
		var err = ResourceSaver.save(tile_set, "res://assets/sprites/tileset.tres")
		if err == OK:
			print("✅ TileSet (tileset.tres) を生成・保存し、当たり判定を自動設定しました！")
		else:
			push_error("❌ TileSet の保存に失敗しました。")
	else:
		push_error("❌ res://assets/sprites/tilesheet.png が見つかりません。")

	# ----------------------------------------------------
	# 2. 現在のシーンのレイヤー構築
	# ----------------------------------------------------
	var scene = get_scene()
	if not scene:
		push_error("❌ 対象のシーンが開かれていません。Mainシーンを開いてから実行してください。")
		return
		
	var saved_tile_set = load("res://assets/sprites/tileset.tres")
		
	if "y_sort_enabled" in scene:
		scene.y_sort_enabled = true
		print("✅ ルートノードの Y-Sort を有効化しました。")
		
	if not scene.has_node("GroundLayer"):
		var ground_layer = TileMapLayer.new()
		ground_layer.name = "GroundLayer"
		ground_layer.z_index = -1
		ground_layer.tile_set = saved_tile_set
		scene.add_child(ground_layer)
		ground_layer.owner = scene
		print("✅ GroundLayer を追加しました。")
		
	if not scene.has_node("ObjectLayer"):
		var object_layer = TileMapLayer.new()
		object_layer.name = "ObjectLayer"
		object_layer.y_sort_enabled = true
		object_layer.tile_set = saved_tile_set
		scene.add_child(object_layer)
		object_layer.owner = scene
		print("✅ ObjectLayer を追加しました。")
		
	var katamari = scene.get_node_or_null("Katamari")
	if katamari and "y_sort_enabled" in katamari:
		katamari.y_sort_enabled = true
		print("✅ Katamari の Y-Sort を有効にしました。")
		
	print("🎉 すべての自動セットアップが完了しました！")
