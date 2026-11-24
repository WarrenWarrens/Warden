extends StaticBody3D

@export var prompt_message: String = "Enter Door"
@export_file("*.tscn") var next_scene_path: String

func interact() -> void:
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		print("No scene path assigned to this door yet lmao")
		

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	pass
