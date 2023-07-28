# Godot 4 - 2D Grid Lighting Demo

implementation based on: https://github.com/nick-paul/LightMask


Godot: https://godotengine.org/

godot-cpp: https://github.com/godotengine/godot-cpp (4.1 branch)


# Demo Usage
- Arrow keys to move the camera
- Move the mouse to highlight an area of the TileMap


# Notes
- Tested on Godot 4.1.1
- CPU based
- Includes GDExtension C++ version, and GDScript version (You will have to compile the GDExtension version yourself)
- Supports multiple lights, different colors, and configurable how much light a tile blocks.
- Does NOT support multiple sizes of lights, another mask would be needed for that
- **GDScript version is included for demonstration purposes, but very slow. It should only be called when an update of lighting is required. C++ version is magnitudes faster.**


# GDExtension
https://docs.godotengine.org/en/latest/tutorials/scripting/gdextension/what_is_gdextension.html

https://docs.godotengine.org/en/latest/tutorials/scripting/gdextension/gdextension_cpp_example.html

tl;dr:
```sh
git clone https://github.com/viraelin/godot4-2d-grid-lighting-demo
cd godot4-2d-grid-lighting-demo
# this is where you clone and build godot-cpp to (or edit SConstruct to point to an existing version for godot-cpp)
scons
```

To switch between c++ and gdscript version, rename references in `main.gd` to `LightMaskGD` and `LightMask`.
