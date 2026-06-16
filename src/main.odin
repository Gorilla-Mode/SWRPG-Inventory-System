package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"

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
    rl.SetWindowIcon(images[ui.icons.app_icon])

    fnt := ui.LoadFont()

    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    for !rl.WindowShouldClose()
    {
        rl.BeginDrawing()
        rl.ClearBackground(palette.surface)

        rl.DrawTextEx(fnt.bold[ui.font_size.title],"SWIS", {20, 5}, f32(ui.font_size.title), 0, palette.text)
        ui.DrawPalette(palette, offset_y = 34)

        rl.EndDrawing()
    }

    gun := inv.Item{
        id = "gun",
    }
}