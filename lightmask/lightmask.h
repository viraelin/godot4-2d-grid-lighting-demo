#pragma once
#include <godot_cpp/classes/ref.hpp>


namespace godot
{

class LightMask: public RefCounted
{
GDCLASS(LightMask, RefCounted)

public:
	LightMask();
	~LightMask();

	void init(const int width, const int height);
	void reset();
	void add_light(const int x, const int y);
	void compute(const Rect2i &r, const PackedFloat32Array &walls);
	PackedColorArray get_mask() { return mask; }

protected:
	static void _bind_methods();

private:
	int m_width;
	int m_height;
	float m_intensity;
	float m_falloff;
	PackedColorArray mask;
	inline int id(int x, int y) {
		x = godot::CLAMP(x, 0, m_width-1);
		y = godot::CLAMP(y, 0, m_height-1);
		return x + y * m_width;
	}
	void forward(const Rect2i &r, const PackedFloat32Array &walls);
	void backward(const Rect2i &r, const PackedFloat32Array &walls);
	float calculate_channel(const float c, const float n1, const float n2, const float wf);
	Color calculate_rgb(const Color &c, const Color &n1, const Color &n2, const float wf);
};
}