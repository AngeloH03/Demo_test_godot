extends CanvasLayer

@export_file("*json") var scene_text_file: String

var scene_text: Dictionary = {}
var selected_text: Array = []
var in_progress: bool = false

@onready var nine_patch_rect: NinePatchRect = $NinePatchRect
@onready var text_label = $TextLabel

func _ready():
	nine_patch_rect.visible = false
	$AnimatedSprite2D.visible = false
	scene_text = load_scene_text()
	SignalBus.connect("display_dialog", _on_display_dialog)

# Load text from JSON file
func load_scene_text():
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		return test_json_conv.get_data()

func show_text():
	var text = selected_text.pop_front()
	text_label.text = text
	text_label.visible_characters = 0
	
	var letterspersecond = 15
	var dialog_size: int = len(text)
	
	var currentTextTween = text_label.create_tween()
	
	currentTextTween.tween_property(
		text_label,
		"visible_characters",
		dialog_size,
		(dialog_size / letterspersecond)
	)
	
	await currentTextTween.finished
	SignalBus.emit_signal("dialog_line_over")
	$AnimatedSprite2D.visible = true

func next_line():
	$AnimatedSprite2D.visible = false
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():
	text_label.text = ""
	nine_patch_rect.visible = false
	in_progress = false
	get_tree().paused = false
	$AnimatedSprite2D.visible = false
	SignalBus.emit_signal("dialog_line_over")

func _on_display_dialog(text_key):
	# If text is already been read
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		nine_patch_rect.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
