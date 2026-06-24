package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import app "core/app"
import str "core:strings"

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
    inv.TestInvGrid(items.backpack, items.sword, items.rifle, items.sword_instance, items.rifle_instance)
    state.InventoryGrid = inv.ContainerToString(items.backpack)

    for !rl.WindowShouldClose()
    {
        grid := str.clone_to_cstring(state.InventoryGrid, context.allocator)
        defer delete_cstring(grid)

        app.InputMoveItem(&state, items.rifle_instance, items.backpack)

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        rl.DrawTextEx(style.fonts.bold[ui.font_size.title],"SWIS", {20, 5}, f32(ui.font_size.title), 0, style.colors.text)
        ui.DrawPalette(style.colors, offset_y = 34)
        //rl.DrawTextEx(fnt.semibold[ui.font_size.header], grid, {20, 34 + 100 + 60}, f32(ui.font_size.header), 10, palette.text)

        inv.DrawContainerGrid(items.backpack, 20, 34 + 100 + 60, 40, &style)

        rl.EndDrawing()
    }
}