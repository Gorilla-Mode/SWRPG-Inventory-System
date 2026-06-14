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

    icon: rl.Image = rl.LoadImage("src/assets/icon/app/cryo-chamber.png")
    rl.ImageFormat(&icon, .UNCOMPRESSED_R8G8B8A8)
    rl.SetWindowIcon(icon)
    rl.UnloadImage(icon)

    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    for !rl.WindowShouldClose()
    {
        rl.BeginDrawing()
        rl.ClearBackground(palette.surface)
        rl.EndDrawing()
    }
}