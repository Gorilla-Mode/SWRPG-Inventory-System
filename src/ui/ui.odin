package ui

import rl "vendor:raylib"

style :: struct{
    icons: map[Icons]rl.Image,
    fonts: fonts,
    colors: color_palette,

    grid: grid
}

grid :: struct{
    origin_x: f32,
    origin_y: f32,
    cell_size: f32
}