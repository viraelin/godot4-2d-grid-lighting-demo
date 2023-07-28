class_name LightMaskGD

var mask: PackedColorArray
var width: int
var height: int
var intensity: float
var falloff: float

func init(w: int, h: int) -> void:
	mask = PackedColorArray()
	width = w
	height = h
	intensity = 16.0
	falloff = 1.0 / intensity
	reset()

func id(x: int,  y: int) -> int:
	x = clampi(x, 0, width-1)
	y = clampi(y, 0, height-1)
	return x + y * width

func reset() -> void:
	mask.resize(width * height)
	mask.fill(Color.BLACK)

func add_light(x: int, y: int) -> void:
	var cc: = Color.WHITE
	mask[id(x, y)] = cc

func compute(region: Rect2i, walls: PackedFloat32Array) -> void:
	_forward(region, walls)
	_backward(region, walls)
	_forward(region, walls)
	_backward(region, walls)

func _forward(r: Rect2i, walls: PackedFloat32Array) -> void:
	for x in range(r.position.x, r.size.x):
		var y: = r.position.y
		mask[id(x, y)] = _calculate_rgb(
			mask[id(x, y)],
			mask[id(x-1, y)],
			Color.BLACK,
			walls[id(x, y)])

	for y in range(r.position.y, r.size.y):
		var fx: = r.position.x
		mask[id(fx, y)] = _calculate_rgb(
			mask[id(fx, y)],
			mask[id(fx, y-1)],
			Color.BLACK,
			walls[id(fx, y)])

		for x in range(r.position.x, r.size.x):
			mask[id(x, y)] = _calculate_rgb(
				mask[id(x, y)],
				mask[id(x-1, y)],
				mask[id(x, y-1)],
				walls[id(x, y)])

func _backward(r: Rect2i, walls: PackedFloat32Array) -> void:
	for x in range(r.position.x+r.size.x-2, r.position.x-1, -1):
		var y: = r.position.y+r.size.y-1
		mask[id(x, y)] = _calculate_rgb(
			mask[id(x, y)],
			mask[id(x+1, y)],
			Color.BLACK,
			walls[id(x, y)])

	for y in range(r.position.y+r.size.y-2, r.position.y-1, -1):
		var fx: = r.position.x+r.size.x-1
		mask[id(fx, y)] = _calculate_rgb(
			mask[id(fx, y)],
			mask[id(fx, y+1)],
			Color.BLACK,
			walls[id(fx, y)])

		for x in range(r.position.x+r.size.x-2, r.position.x-1, -1):
			mask[id(x, y)] = _calculate_rgb(
				mask[id(x, y)],
				mask[id(x+1, y)],
				mask[id(x, y+1)],
				walls[id(x, y)])

func _calculate_channel(c: float, n1: float, n2: float, wf: float) -> float:
	return maxf(0.0, maxf(maxf(c, n1), maxf(c, n2)) - minf(1.0, falloff + wf))

func _calculate_rgb(c: Color, n1: Color, n2: Color, wf: float) -> Color:
	# other color channels disabled for slight perf gain in gdscript demo
	var r: = _calculate_channel(c.r, n1.r, n2.r, wf)
#	var g: = _calculate_channel(c.g, n1.g, n2.g, wf)
#	var b: = _calculate_channel(c.b, n1.b, n2.b, wf)
#	var color: = Color(r, g, b, 1.0)
	var color: = Color(r, r, r, 1.0)
	return color
