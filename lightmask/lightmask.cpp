#include "lightmask.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;


void LightMask::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("init", "width", "height"), &LightMask::init);
	ClassDB::bind_method(D_METHOD("reset"), &LightMask::reset);
	ClassDB::bind_method(D_METHOD("add_light", "x", "y"), &LightMask::add_light);
	ClassDB::bind_method(D_METHOD("compute", "walls", "region"), &LightMask::compute);
	ClassDB::bind_method(D_METHOD("get_mask"), &LightMask::get_mask);
	ClassDB::add_property("LightMask", PropertyInfo(Variant::PACKED_FLOAT32_ARRAY, "mask", PROPERTY_HINT_NONE), "", "get_mask");
}

LightMask::LightMask()
{
}

LightMask::~LightMask()
{
}


void LightMask::init(const int width, const int height)
{
	PackedColorArray mask = PackedColorArray();
	m_width = width;
	m_height = height;
	m_intensity = 16.0;
	m_falloff = 1.0 / m_intensity;
	reset();
}

void LightMask::reset()
{
	mask.resize(m_width * m_height);
	mask.fill(Color(0.0f, 0.0f, 0.0f));
}

void LightMask::add_light(const int x, const int y)
{
	mask[id(x, y)] = Color(1.0f, 1.0f, 1.0f);
}

void LightMask::compute(const Rect2i &r, const PackedFloat32Array &walls)
{
	forward(r, walls);
	backward(r, walls);
	forward(r, walls);
	backward(r, walls);
}

void LightMask::forward(const Rect2i &r, const PackedFloat32Array &walls)
{
	for (int x=r.position.x; x<r.size.x; ++x)
	{
		const int y = r.position.y;
		mask[id(x, y)] = calculate_rgb(
			mask[id(x, y)],
			mask[id(x-1, y)],
			Color(0.0f, 0.0f, 0.0f),
			walls[id(x, y)]);
	}

	for (int y=r.position.y; y<r.size.y; ++y)
	{
		const int fx = r.position.x;
		mask[id(fx, y)] = calculate_rgb(
			mask[id(fx, y)],
			mask[id(fx, y-1)],
			Color(0.0f, 0.0f, 0.0f),
			walls[id(fx, y)]);

		for (int x=r.position.x; x<r.size.x; ++x)
		{
			mask[id(x, y)] = calculate_rgb(
				mask[id(x, y)],
				mask[id(x-1, y)],
				mask[id(x, y-1)],
				walls[id(x, y)]);
		}
	}
}

void LightMask::backward(const Rect2i &r, const PackedFloat32Array &walls)
{
	for (int x=r.position.x+r.size.x-2; x>r.position.x-1; --x)
	{
		const int y = r.position.y+r.size.y-1;
		mask[id(x, y)] = calculate_rgb(
			mask[id(x, y)],
			mask[id(x+1, y)],
			Color(0.0f, 0.0f, 0.0f),
			walls[id(x, y)]);
	}

	for (int y=r.position.y+r.size.y-2; y>r.position.y-1; --y)
	{
		const int fx = r.position.x+r.size.x-1;
		mask[id(fx, y)] = calculate_rgb(
			mask[id(fx, y)],
			mask[id(fx, y+1)],
			Color(0.0f, 0.0f, 0.0f),
			walls[id(fx, y)]);

		for (int x=r.position.x+r.size.x-2; x>r.position.x-1; --x)
		{
			mask[id(x, y)] = calculate_rgb(
				mask[id(x, y)],
				mask[id(x+1, y)],
				mask[id(x, y+1)],
				walls[id(x, y)]);
		}
	}
}

float LightMask::calculate_channel(const float c, const float n1, const float n2, const float wf)
{
	return std::max(0.0f, std::max(std::max(c, n1), std::max(c, n2)) - std::min(1.0f, m_falloff + wf));
}

Color LightMask::calculate_rgb(const Color &c, const Color &n1, const Color &n2, const float wf)
{
	const float r = calculate_channel(c.r, n1.r, n2.r, wf);
	const float g = calculate_channel(c.g, n1.g, n2.g, wf);
	const float b = calculate_channel(c.b, n1.b, n2.b, wf);
	return Color(r, g, b);
}
