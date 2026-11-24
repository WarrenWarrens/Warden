
extends CanvasLayer

var paused = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	visible = false
	get_tree().paused = false

func toggle_pause_menu():
	paused = !paused 
	get_tree().paused = paused
	
	if paused:
		visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		toggle_pause_menu()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	pass

func _on_resume_button_pressed() -> void:
	toggle_pause_menu()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")
