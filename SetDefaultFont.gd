@tool
extends EditorScript

func _run():
    var font_path = "res://assets/fonts/NotoSansJP-VariableFont_wght.ttf"
    
    # デフォルトのカスタムフォントパスを設定
    ProjectSettings.set_setting("gui/theme/custom_font", font_path)
    
    # ProjectSettings上でファイル選択ダイアログなどが正しく動作するように、プロパティのヒント情報を追加
    ProjectSettings.add_property_info({
        "name": "gui/theme/custom_font",
        "type": TYPE_STRING,
        "hint": PROPERTY_HINT_FILE,
        "hint_string": "*.ttf,*.otf,*.woff,*.woff2,*.font,*.tres"
    })
    
    # 設定を project.godot に保存
    var err = ProjectSettings.save()
    if err == OK:
        print("デフォルトフォントを '%s' に設定し、保存しました！" % font_path)
    else:
        push_error("プロジェクト設定の保存に失敗しました。エラーコード: " + str(err))
