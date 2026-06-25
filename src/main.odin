package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import app "core/app"

window_width: i32 = 1280
window_height: i32 = 720

main :: proc()
{
    defer rl.CloseWindow()

    style := ui.style{}

    style.colors = ui.LoadColorPalette()

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(window_width, window_height, "SWIS")
    util.SetDarkTitlebar()

    style.icons = ui.LoadImages()
    defer delete(style.icons)
    rl.SetWindowIcon(style.icons[ui.Icons.app_icon])

    style.fonts = ui.LoadFont()
    defer ui.FreeFont(style.fonts)

    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    state := app.State{}
    items := inv.TestItem()

    for !rl.WindowShouldClose()
    {
        grid_x: f32 = 20
        grid_y: f32 = 34 + 100 + 60
        grid_size: f32 = 50

        app.InputMoveItem(&state, items.rifle_instance, items.backpack, grid_x, grid_y, grid_size)

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        rl.DrawTextEx(style.fonts.bold[ui.font_size.title],"SWIS", {20, 5}, f32(ui.font_size.title), 0, style.colors.text)
        ui.DrawPalette(style.colors, offset_y = 34)

        inv.DrawContainerGrid(items.backpack, grid_x, grid_y, grid_size, &style)

        if state.is_dragging {
            inv.DrawItemGhost(items.rifle_instance, state.ghost_pos_x, state.ghost_pos_y, state.ghost_rotated, state.ghost_valid, grid_x, grid_y, grid_size, &style)
        }

        rl.EndDrawing()
    }
}