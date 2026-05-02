extends Node2D

func _process(_delta):
    # 毎フレーム再描画をリクエスト
    queue_redraw()

func _draw():
    var cam = get_viewport().get_camera_2d()
    if not cam: return
    
    var cam_pos = cam.global_position
    var view_size = get_viewport_rect().size / cam.zoom
    var step = 100 # グリッドの幅
    
    # 画面の端から端まで線を引く
    var start_x = fposmod(cam_pos.x - view_size.x / 2.0, step)
    var start_y = fposmod(cam_pos.y - view_size.y / 2.0, step)
    
    for x in range(int(view_size.x / step) + 2):
        var world_x = (cam_pos.x - view_size.x / 2.0) - start_x + (x * step)
        draw_line(Vector2(world_x, cam_pos.y - view_size.y), Vector2(world_x, cam_pos.y + view_size.y), Color(0.3, 0.3, 0.3, 0.5), 2.0)
        
    for y in range(int(view_size.y / step) + 2):
        var world_y = (cam_pos.y - view_size.y / 2.0) - start_y + (y * step)
        draw_line(Vector2(cam_pos.x - view_size.x, world_y), Vector2(cam_pos.x + view_size.x, world_y), Color(0.3, 0.3, 0.3, 0.5), 2.0)
