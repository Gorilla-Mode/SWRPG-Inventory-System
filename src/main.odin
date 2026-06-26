package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import app "core/app"
import v "view"

window_width: i32 = 1280
window_height: i32 = 720

main :: proc()
{
    defer rl.CloseWindow()

    state := app.State{}
    items := inv.TestItem()

    style := ui.style{
        grid = {
            cell_size = 50,
            origin_x = 20,
            origin_y = 34 + 100 + 60,
        }
    }

    style.icons = ui.LoadImages()
    style.colors = ui.LoadColorPalette()
    defer delete(style.icons)

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(window_width, window_height, "SWIS")
    util.SetDarkTitlebar()
    rl.SetWindowIcon(style.icons[ui.Icons.app_icon])
    rl.SetTargetFPS(180)
    rl.SetExitKey(nil)

    style.fonts = ui.LoadFont()
    defer ui.FreeFont(style.fonts)

    for !rl.WindowShouldClose()
    {
        app.InputMoveItem(&state,
        items.backpack,
        style.grid.origin_x,
        style.grid.origin_y,
        style.grid.cell_size)

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        rl.DrawTextEx(style.fonts.bold[ui.font_size.title],
        "SWIS",
        {20, 5},
        f32(ui.font_size.title),
        0,
        style.colors.text)
        ui.DrawPalette(style.colors, offset_y = 34)

        v.DrawGrid(items.backpack, &state, &style)

        rl.EndDrawing()
    }
}