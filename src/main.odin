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

    state := app.State{}
    items := inv.TestItem()

    style := ui.style{
        grid = {
            cell_size = 50
        }
    }

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
        grid := items.backpack.storage.(inv.ContainerGrid)
        grid_h := style.grid.cell_size * f32(grid.height)
        grid_w := style.grid.cell_size * f32(grid.width)

        style.grid.origin_y = (state.window.height - grid_h) / 2
        style.grid.origin_x = (state.window.width - grid_w) / 2

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