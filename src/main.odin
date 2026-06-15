package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"

window_width: i32 = 1280
window_height: i32 = 720

main :: proc()
{
    defer rl.CloseWindow()

    palette:= ui.load_color_palette()

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(window_width, window_height, "SWIS")
    util.set_dark_title_bar()

    images := ui.load_images()
    rl.SetWindowIcon(images[ui.icons.app])

    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    for !rl.WindowShouldClose()
    {
        rl.BeginDrawing()
        rl.ClearBackground(palette.surface)

        rl.DrawText("SWIS", 20, 10, 24, palette.text)
        ui.draw_palette(palette, offset_y = 34)

        rl.EndDrawing()
    }
}