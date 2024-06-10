class_name Main
extends Node


const CONFIG_PATH: String = "user://config.json"
const BACKUPS_DIR_PATH: String = "user://Backups"

@export var game_info_scene: PackedScene

var _aoh2_file_path: String = "":
	set(value):
		_aoh2_file_path = value
		while (
				_aoh2_file_path.length() > 0
				and
				_aoh2_file_path.unicode_at(_aoh2_file_path.length() - 1) < 32
		):
			_aoh2_file_path = _aoh2_file_path.left(-1)
		if _aoh2_file_path.ends_with("/saves"):
			_aoh2_file_path += "/games"
		elif _aoh2_file_path.ends_with("/AoCII"):
			_aoh2_file_path += "/saves/games"
		path_label.text = _aoh2_file_path

@onready var file_dialog := %FileDialog as FileDialog
@onready var path_label := %PathLabel as Label
@onready var error_label := %ErrorLabel as Label
@onready var top_nodes := %TopNodes as Control
@onready var label_1 := %Label1 as Label
@onready var container := %HBoxContainer as Control
@onready var fix_0_relations := %FixZeroRelations as Control
@onready var feedback_label := %Feedback as Label
@onready var backup_feedback_label := %BackupFeedback as Label
@onready var helpful_label := %HelpfulLabel as Label
@onready var default_relations_section := %DefaultRelationsSection as Control
@onready var default_relations_box := %DefaultRelations as SpinBox
@onready var feedback_animation := %FeedbackAnimation as AnimationPlayer
@onready var backup_fb_animation := %BackupFbAnimation as AnimationPlayer


func _ready() -> void:
	_load_config()
	feedback_label.hide()
	backup_feedback_label.hide()


func _load_config() -> void:
	_show_error_nodes()
	
	var config: String = FileAccess.get_file_as_string(CONFIG_PATH)
	if config == "":
		return
	
	var lines: PackedStringArray = config.split("\n")
	_aoh2_file_path = lines[0]
	lines.remove_at(0)
	default_relations_box.value = lines[0].to_float()
	lines.remove_at(0)
	
	_find_save_files()
	
	if container.get_children().size() == 0:
		return
	
	var game_info_nodes: Array[GameInfo] = []
	for node in container.get_children():
		game_info_nodes.append(node as GameInfo)
	
	if game_info_nodes.size() >= lines.size():
		for i in lines.size():
			if i >= game_info_nodes.size():
				break
			if lines[i] != "":
				game_info_nodes[i].check_box.set_pressed_no_signal(true)
				game_info_nodes[i]._on_check_box_toggled(true)
	
	_count_number_of_saves()


func _save_config() -> void:
	var string := ""
	string += _aoh2_file_path + "\n" + str(default_relations_box.value)
	for node in container.get_children():
		string += "\n"
		if (node as GameInfo).check_box.button_pressed:
			string += "x"
	
	var config := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	config.store_string(string)
	config.close()


func _show_error_nodes() -> void:
	error_label.show()
	top_nodes.hide()
	_hide_operations()


func _show_no_error_nodes() -> void:
	error_label.hide()
	top_nodes.show()
	_hide_operations()


func _hide_operations() -> void:
	fix_0_relations.hide()
	helpful_label.hide()
	default_relations_section.hide()


func _show_operations(has_one_save_selected: bool) -> void:
	fix_0_relations.visible = has_one_save_selected
	helpful_label.visible = not has_one_save_selected
	default_relations_section.visible = has_one_save_selected


func _find_save_files() -> void:
	for node in container.get_children():
		container.remove_child(node)
		node.queue_free()
	
	_check_dirs_recursive(_aoh2_file_path, 0)


func _check_dirs_recursive(dir_path: String, current_depth: int) -> void:
	if _is_dir_saved_game(dir_path):
		_show_no_error_nodes()
		return
	
	# Prevent freeze when the user selects
	# a folder that contains a LOT of stuff
	if current_depth >= 5:
		return
	
	for dir in DirAccess.get_directories_at(dir_path):
		_check_dirs_recursive(dir_path + "/" + dir, current_depth + 1)


## Currently only checks if the directory contains
## the .json file and the _2X file
func _is_dir_saved_game(dir_path: String) -> bool:
	var dir_name: String = GameInfo.dir_name_of(dir_path)
	
	var json_string: String = FileAccess.get_file_as_string(
			dir_path + "/" + dir_name + ".json"
	)
	if json_string == "":
		return false
	
	var _2X: PackedByteArray = FileAccess.get_file_as_bytes(
			dir_path + "/" + dir_name + "_2X"
	)
	if _2X.is_empty():
		return false
	
	_create_game_info_node(dir_path, json_string)
	return true


func _create_game_info_node(dir_path: String, json_string: String) -> void:
	var game_info_node := game_info_scene.instantiate() as GameInfo
	game_info_node.dir_path = dir_path
	game_info_node.init(json_string)
	container.add_child(game_info_node)
	game_info_node.check_box.toggled.connect(_on_game_info_checkbox_toggled)


func _count_number_of_saves() -> void:
	var number: int = 0
	var number_selected: int = 0
	for node in container.get_children():
		number += 1
		if (node as GameInfo).check_box.button_pressed:
			number_selected += 1
	label_1.text = str(number) + " saved game"
	if number != 1:
		label_1.text += "s"
	label_1.text += " (" + str(number_selected) + " selected)"
	_show_operations(number_selected > 0)


func _select_all(is_selected: bool) -> void:
	for node in container.get_children():
		(node as GameInfo).check_box.set_pressed_no_signal(is_selected)
		(node as GameInfo)._on_check_box_toggled(is_selected)
	_save_config()
	_count_number_of_saves()


func _on_button_pressed() -> void:
	if _aoh2_file_path != "":
		file_dialog.current_path = _aoh2_file_path
	file_dialog.show()


func _on_file_dialog_dir_selected(dir: String) -> void:
	_aoh2_file_path = dir
	_save_config()
	_load_config()


func _on_game_info_checkbox_toggled(_is_selected: bool) -> void:
	_save_config()
	_count_number_of_saves()


func _on_refresh_button_pressed() -> void:
	_load_config()


func _on_all_button_pressed() -> void:
	_select_all(true)


func _on_none_button_pressed() -> void:
	_select_all(false)


func _on_fix_zero_relations_pressed() -> void:
	var time_stamp: String = (
			Time.get_datetime_string_from_unix_time(
					floori(Time.get_unix_time_from_system())
			).replace("T", "-").replace(":", "-")
			+ "-" + str(Time.get_ticks_msec() % 1000)
	)
	
	var number_of_new_backups: int = 0
	var total_nans_removed: int = 0
	for node in container.get_children():
		if (node as GameInfo).check_box.button_pressed:
			var fix := ZeroRelationsFix.new()
			fix.fix(node as GameInfo, time_stamp, default_relations_box.value)
			number_of_new_backups += fix.number_of_new_backups
			total_nans_removed += fix.number_of_nans_removed
	
	if number_of_new_backups > 0:
		backup_feedback_label.modulate = Color(0.5, 1.0, 0.5, 1.0)
		backup_feedback_label.text = (
				"+" + str(number_of_new_backups) + " backups"
		)
		backup_feedback_label.show()
		backup_fb_animation.stop()
		backup_fb_animation.play("feedback_fadeout")
	
	feedback_label.modulate = Color(0.5, 1.0, 0.5, 1.0)
	feedback_label.text = (
			"Fixed " + str(total_nans_removed) + " bugged relations"
	)
	feedback_label.show()
	feedback_animation.stop()
	feedback_animation.play("feedback_fadeout")


func _on_backups_button_pressed() -> void:
	if not DirAccess.dir_exists_absolute(BACKUPS_DIR_PATH):
		DirAccess.make_dir_absolute(BACKUPS_DIR_PATH)
	OS.shell_open(ProjectSettings.globalize_path(BACKUPS_DIR_PATH))


func _on_default_relations_value_changed(_value: float) -> void:
	_save_config()
