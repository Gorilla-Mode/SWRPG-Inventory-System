package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"

window_width: i32 = 1280
window_height: i32 = 720

main :: proc()
{
    defer rl.CloseWindow()

    palette:= ui.LoadColorPalette()

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(window_width, window_height, "SWIS")
    util.SetDarkTitlebar()

    images := ui.LoadImages()
    rl.SetWindowIcon(images[ui.icons.app])

    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    for !rl.WindowShouldClose()
    {
        rl.BeginDrawing()
        rl.ClearBackground(palette.surface)

        rl.DrawText("SWIS", 20, 10, 24, palette.text)
        ui.DrawPalette(palette, offset_y = 34)

        rl.EndDrawing()
    }
}