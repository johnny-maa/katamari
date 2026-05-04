@tool
extends EditorScript

func _run():
	# レンダリングメソッドを互換性(Compatibility)モードに変更
	ProjectSettings.set_setting("rendering/renderer/rendering_method", "gl_compatibility")
	ProjectSettings.set_setting("rendering/renderer/rendering_method.mobile", "gl_compatibility")
	
	# プロジェクト設定を保存
	var err = ProjectSettings.save()
	if err == OK:
		print("レンダラーを「Compatibility」に変更し、保存しました！Godotエディタを再起動してください。")
	else:
		print("設定の保存に失敗しました。エラーコード: ", err)
