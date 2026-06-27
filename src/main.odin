package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import app "core/app"
import v "view"
import st "core/state"

main :: proc()
{
    defer rl.CloseWindow()

    style := ui.style{
        grid = {
            cell_size = 50
        }
    }

    state := st.State{}
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
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))

    rl.SetExitKey(nil)

    style.fonts = ui.LoadFont()
    defer ui.FreeFont(style.fonts)

    for !rl.WindowShouldClose()
    {
        //rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
        st.UpdateWindowState(&state)

        app.InputMoveItem(&state,
        items.backpack,
        style.grid.origin_x,
        style.grid.origin_y,
        style.grid.cell_size)

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        v.DrawHeader(&style, &state)
        v.DrawGrid(items.backpackItem, &state, &style)
        v.DrawDebug(&state, &style)

        rl.EndDrawing()
    }
}