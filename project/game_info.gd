class_name GameInfo
extends Control


@export var color_selected: Color
@export var color_not_selected: Color

var dir_path: String

@onready var color_rect := %ColorRect as ColorRect
@onready var check_box := %CheckBox as CheckBox
@onready var _feedback_color := %FeedbackColor as ColorRect
@onready var _animation_player := %AnimationPlayer as AnimationPlayer


func _ready() -> void:
	_feedback_color.color = Color(1.0, 1.0, 1.0, 0.0)
	_on_check_box_toggled(check_box.button_pressed)


func init(json_string: String) -> void:
	var json_data: Variant = JSON.parse_string(json_string)
	if not (json_data is Dictionary):
		return
	var json_dict := json_data as Dictionary
	if not (json_dict.has("Data_Save_Info")):
		return
	var save_info: Variant = json_dict["Data_Save_Info"]
	if not (save_info is Array):
		return
	var save_info_array := save_info as Array
	if save_info_array.size() == 0:
		return
	var save_info_element: Variant = save_info_array[0]
	if not (save_info_element is Dictionary):
		return
	var save_info_dict := save_info_element as Dictionary
	
	var label := %Text as RichTextLabel
	label.text = ""
	label.text += "PLAYER_TAG:\n"
	if save_info_dict.has("PLAYER_TAG"):
		label.text += str(save_info_dict["PLAYER_TAG"])
	label.text += "\n\n" + "GameDate:\n"
	if save_info_dict.has("GameDate"):
		label.text += str(save_info_dict["GameDate"])
	label.text += "\n\n" + "Turn:\n"
	if save_info_dict.has("Turn"):
		label.text += str(save_info_dict["Turn"])
	label.text += "\n\n" + "Civs:\n"
	if save_info_dict.has("Civs"):
		label.text += str(save_info_dict["Civs"])


func play_feedback_animation(is_success: bool) -> void:
	if is_success:
		_feedback_color.color = Color(0.5, 1.0, 0.5, 1.0)
	else:
		_feedback_color.color = Color(0.75, 0.75, 0.75, 1.0)
	_animation_player.stop()
	_animation_player.play("feedback")


static func dir_name_of(dir_path_: String) -> String:
	return dir_path_.split("/")[-1]


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		color_rect.color = color_selected
	else:
		color_rect.color = color_not_selected
