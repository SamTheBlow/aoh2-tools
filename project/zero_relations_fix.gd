class_name ZeroRelationsFix
## Fixes the zero relations bug in an AOH2 save file by
## replacing all occurences of NaN with any given float number.


var number_of_new_backups: int = 0
var number_of_nans_removed: int = 0


## The time stamp is for the backup file name
func fix(
		game_info: GameInfo,
		time_stamp: String,
		replacement_value: float = 10.0
) -> void:
	number_of_new_backups = 0
	number_of_nans_removed = 0
	
	var dir_path: String = game_info.dir_path
	var dir_name: String = GameInfo.dir_name_of(dir_path)
	var _2X_files: Array[PackedByteArray] = []
	
	_2X_files.append(
			FileAccess.get_file_as_bytes(dir_path + "/" + dir_name + "_2X")
	)
	
	var j: int = 1
	while true:
		var _2Xn: PackedByteArray = FileAccess.get_file_as_bytes(
				dir_path + "/" + dir_name + "_2X" + str(j)
		)
		if _2Xn.is_empty():
			break
		_2X_files.append(_2Xn)
		j += 1
	
	var replacement_bytes: PackedByteArray = var_to_bytes(replacement_value)
	for byte_array in _2X_files:
		for i in byte_array.size() - 3:
			if (
					byte_array[i] == 0x7F
					and byte_array[i + 1] == 0xC0
					and byte_array[i + 2] == 0x00
					and byte_array[i + 3] == 0x00
			):
				byte_array[i] = replacement_bytes[7]
				byte_array[i + 1] = replacement_bytes[6]
				byte_array[i + 2] = replacement_bytes[5]
				byte_array[i + 3] = replacement_bytes[4]
				number_of_nans_removed += 1
			i += 3
	
	if number_of_nans_removed == 0:
		game_info.play_feedback_animation(false)
		return
	
	# Create new backup
	DirectoryCopy.copy_directory(
			dir_path,
			Main.BACKUPS_DIR_PATH + "/" + time_stamp + "/" + dir_name
	)
	number_of_new_backups += 1
	
	# Save changes
	for i in _2X_files.size():
		var file_name: String = "_2X"
		if i > 0:
			file_name += str(i)
		
		var file_access := FileAccess.open(
				dir_path + "/" + dir_name + file_name, FileAccess.WRITE
		)
		file_access.store_buffer(_2X_files[i])
		file_access.close()
	
	game_info.play_feedback_animation(true)
