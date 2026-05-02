@tool
extends EditorScript

func _run():
	var autoload_name = "GameManager"
	var autoload_path = "res://GameManager.gd"
	var property_name = "autoload/" + autoload_name
	
	# Autoloadとして登録（*をつけることでGlobal変数として扱われる）
	ProjectSettings.set_setting(property_name, "*" + autoload_path)
	
	# 設定を保存
	var error = ProjectSettings.save()
	if error == OK:
		print("✅ 成功: '%s' をAutoloadに登録しました。(%s)" % [autoload_name, autoload_path])
	else:
		print("❌ エラー: ProjectSettingsの保存に失敗しました。")
