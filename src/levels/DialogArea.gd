extends Area2D

@export var dialog_key: String = ""
var is_dialog_line_over: bool = true

var area_active: bool = false

@onready var interaction_label: Label = $InteractionLabel
var action_events = InputMap.action_get_events("interact")[0]
var input_key_code = action_events.physical_keycode
var input_key_string = OS.get_keycode_string(input_key_code)

func _ready() -> void:
	interaction_label.visible = false
	interaction_label.text = input_key_string
	SignalBus.connect("dialog_line_over", _on_dialog_line_over)

func _input(event):
	if is_dialog_line_over and area_active and event.is_action_pressed("interact"):
		is_dialog_line_over = false
		SignalBus.emit_signal("display_dialog", dialog_key)

func _on_dialog_line_over():
	is_dialog_line_over = true

func _on_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	area_active = true
	interaction_label.visible = true

func _on_area_shape_exited(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	area_active = false
	interaction_label.visible = false
