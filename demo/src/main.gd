extends Node2D

var lightmask: LightMaskGD
var lights_image: Image
var lights_image_texture: ImageTexture

var width: int
var height: int

var walls: = PackedFloat32Array()

@onready var tilemap: TileMap = find_child("TileMap")

enum TileType {
	None,
	Solid,
	Glass,
}

const TileTypeFalloff: = {
	TileType.None: 0.0,
	TileType.Solid: 1.0 / 8.0,
	TileType.Glass: 1.0 / 32.0,
}

func _ready() -> void:
	var tilemap_rect: = tilemap.get_used_rect()
	var tile_size: = tilemap.tile_set.tile_size

	width = tilemap_rect.size.x
	height = tilemap_rect.size.y

	lightmask = LightMaskGD.new()
	lightmask.init(width, height)

	lights_image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	lights_image.fill(Color.BLACK)
	lights_image_texture = ImageTexture.create_from_image(lights_image)

	$SubViewport/TextureRect.texture = lights_image_texture
	$SubViewport/TextureRect.size.x = width * tile_size.x
	$SubViewport/TextureRect.size.y = height * tile_size.y

	$SubViewport/Camera2D.position = $Camera2D.position
	$SubViewport/Camera2D.zoom = $Camera2D.zoom

	walls.resize(width * height)
	walls.fill(0.0)

	for x in range(0, width):
		for y in range(0, height):
			var tile_data: = tilemap.get_cell_tile_data(0, Vector2i(x, y))
			var tile_falloff: float

			if tile_data:
				if tile_data.terrain == 0:
					tile_falloff = TileTypeFalloff[TileType.Solid]
				elif tile_data.terrain == 1:
					tile_falloff = TileTypeFalloff[TileType.Glass]
				else:
					tile_falloff = TileTypeFalloff[TileType.Solid]
			else:
				tile_falloff = TileTypeFalloff[TileType.None]

			walls[id(x, y)] = tile_falloff

var _counter: = 0
var _rate: = int(1.0 / 2.0)
func _physics_process(delta: float) -> void:
	var ms: = 100.0 * delta

	if Input.is_action_pressed("ui_left"):
		$Camera2D.position.x -= ms
	if Input.is_action_pressed("ui_right"):
		$Camera2D.position.x += ms
	if Input.is_action_pressed("ui_up"):
		$Camera2D.position.y -= ms
	if Input.is_action_pressed("ui_down"):
		$Camera2D.position.y += ms

	$SubViewport/Camera2D.position = $Camera2D.position

	_counter += 1
	if _counter > _rate:
		_counter = 0
		run()

func id(x: int,  y: int) -> int:
	x = clampi(x, 0, width-1)
	y = clampi(y, 0, height-1)
	return x + y * width

var _prev_grid_pos: = Vector2i()
func run() -> void:
	var pos: = tilemap.local_to_map(tilemap.to_local(get_global_mouse_position()))
	if pos == _prev_grid_pos:
		return

	_prev_grid_pos = pos

	var region: = Rect2i(0, 0, width, height)

	lightmask.reset()
	lightmask.add_light(pos.x, pos.y)
	lightmask.compute(region, walls)

	lights_image.fill(Color.BLACK)

	for x in range(0, width):
		for y in range(0, height):
			var c: = lightmask.mask[id(x, y)]
			lights_image.set_pixel(x, y, c)

	lights_image_texture.update(lights_image)
