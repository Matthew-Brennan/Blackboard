extends Control

var brush_color = Color(1, 1, 1)  # Default white color
var brush_size = 1.0  # Default brush size
var drawing = false
var draw_canvas_item
var last_position
var drawn_items = []

func _ready():
	$DrawingArea.connect("gui_input", Callable(self, "_on_DrawingArea_gui_input"))
	$RefreshButton.connect("pressed", Callable(self, "_on_RefreshButton_pressed"))
	$ColorPickerButton.connect("color_changed", Callable(self, "_on_ColorPickerButton_color_changed"))
	$BrushSizeSlider.connect("value_changed", Callable(self, "_on_BrushSizeSlider_value_changed"))
	draw_canvas_item = $DrawingArea.get_canvas_item()

func _on_DrawingArea_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			drawing = event.pressed
			last_position = event.position
	elif event is InputEventMouseMotion and drawing:
		var current_position = event.position
		var delta = current_position - last_position
		var distance = delta.length()
		var step = 1.0 / distance if distance > 0 else 0.0
		for i in range(0, int(distance)):
			var interpolated_position = last_position + delta * (i * step)
			add_circle(interpolated_position, brush_size, brush_color)
		last_position = current_position

func add_circle(position, radius, color):
	var draw = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(draw, draw_canvas_item)
	RenderingServer.canvas_item_add_circle(draw, position, radius, color)
	drawn_items.append(draw)

func _on_RefreshButton_pressed():
	clear_drawing_area()
	$DrawingArea._draw()

func _on_ColorPickerButton_color_changed(color):
	brush_color = color

func _on_BrushSizeSlider_value_changed(value):
	brush_size = value

func clear_drawing_area():
	for item in drawn_items:
		RenderingServer.free_rid(item)
	drawn_items.clear()
