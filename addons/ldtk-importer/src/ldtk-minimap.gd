@tool

const Util = preload("../util/util.gd")


static func get_minimap_save_path(source_file: String, is_external_level := false) -> String:
	var save_path = Util.get_save_folder_path(source_file, is_external_level) + "/minimaps"
	return save_path


static func create_level_mini_map(
	level_data: Dictionary, source_file: String, options: Dictionary, is_external_level := false
) -> void:
	var save_path = get_minimap_save_path(source_file, is_external_level)
	var extension = "png"
	var save_file_name = level_data.identifier + "." + extension
	var ignore_layers = options.Ignore_Data_Layers.split(",", false)
	var ignore_values = options.Ignore_Data_Values.split_floats(",", false)
	var bg_color := Color(level_data.__bgColor)
	var directory := DirAccess.open(source_file.get_base_dir())
	directory.make_dir_recursive(save_path)

	var width: int = level_data.pxWid / 8
	var height: int = level_data.pxHei / 8
	var data_layer = null
	var colors = {}

	var img = Image.new()
	img.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(bg_color)

	for layer in level_data.layerInstances:
		if layer.__type == "IntGrid" and not ignore_layers.has(layer.__identifier):
			var cols = int(layer.__cWid)
			var rows = int(layer.__cHei)
			var layer_data = layer.intGridCsv

			for index in layer_data.size():
				var cell = int(layer_data[index])
				var x = floor(index % cols)
				var y = floor(index / cols)

				if cell != 0 and not ignore_values.has(cell):
					var color = Color(cell * 100)
					color.a = 1.0
					color.r = color.b
					color.g = color.b
					img.set_pixel(x, y, color)

	var path = save_path + "/" + save_file_name
	var err = img.save_png(path)
	var err_s = ResourceSaver.save(img, path, ResourceSaver.FLAG_COMPRESS)

	var ep = EditorPlugin.new()
	ep.get_editor_interface().get_resource_filesystem().update_file(path)
	ep.free()
