package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import app "core/app"
import v "view"

main :: proc()
{
    defer rl.CloseWindow()

    style := ui.style{
        grid = {
            cell_size = 50
        }
    }

    state := app.State{}
    items := inv.TestItem(style.grid.cell_size)

    style.icons = ui.LoadImages()
    style.colors = ui.LoadColorPalette()
    defer delete(style.icons)

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(1280, 720, "SWIS")
    util.SetDarkTitlebar()
    rl.SetWindowIcon(style.icons[ui.Icons.app_icon])
    rl.SetTargetFPS(180)
    rl.SetExitKey(nil)

    style.fonts = ui.LoadFont()
    defer ui.FreeFont(style.fonts)

    for !rl.WindowShouldClose()
    {
        app.UpdateWindowState(&state)
        gridCenter := v.GridGetCenter(inv.ContainerGridPixelsXY(items.backpack, style.grid.cell_size), &state)
        style.grid.origin_x = gridCenter.x
        style.grid.origin_y = gridCenter.y

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

        v.DrawGrid(items.backpack, &state, &style)
        v.DrawDebug(&state, &style)

        rl.EndDrawing()
    }
}