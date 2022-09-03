tool
extends StaticBody


func _ready() -> void:
	var _mesh_inst: MeshInstance = $MeshInstance
	var _material: SpatialMaterial
	randomize()
	match randi() % 4:
		0: 
			_material = preload("res://src/level_components/environment/shipping_container/shipping_container_blue.material")

		1: 
			_material = preload("res://src/level_components/environment/shipping_container/shipping_container_green.material")

		2: 
			_material = preload("res://src/level_components/environment/shipping_container/shipping_container_yellow.material")

		_: 
			_material = preload("res://src/level_components/environment/shipping_container/shipping_container_red.material")
	
	_mesh_inst.set_surface_material(0, _material)
