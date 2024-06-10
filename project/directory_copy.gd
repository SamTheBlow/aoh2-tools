class_name DirectoryCopy
## Copies any given folder to any given path.
## I don't understand why Godot doesn't provide this out of the box.
##
## The code was mostly taken from here:
## https://www.reddit.com/r/godot/comments/19f0mf2/is_there_a_way_to_copy_folders_from_res_to_user/


# Recursive function
## Both parameters must be absolute paths to a directory.
static func copy_directory(from_path: String, to_path: String) -> void:
	# Make sure the paths end with a "/"
	from_path = from_path if from_path.ends_with("/") else from_path + "/"
	to_path = to_path if to_path.ends_with("/") else to_path + "/"
	
	DirAccess.make_dir_recursive_absolute(to_path)
	
	var source_dir := DirAccess.open(from_path)
	
	for file_name in source_dir.get_files():
		source_dir.copy(from_path + file_name, to_path + file_name)
	
	for dir_name in source_dir.get_directories():
		DirectoryCopy.copy_directory(from_path + dir_name, to_path + dir_name)
