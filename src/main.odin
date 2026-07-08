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

    state := st.state{textFields = make(map[st.textField]st.textFieldState)}
    state.ItemRegistry = inv.MakeItemRegistry()
    inv.TestRegistry(&state.ItemRegistry)
    items := inv.TestItemInstance(style.grid.cell_size, &state.ItemRegistry)
    state.character = inv.TestCharacter(items.backpackInstance, &state.ItemRegistry)
    defer delete(state.textFields)
    defer delete(state.ItemRegistry.items)

    window_flags := rl.ConfigFlags{
        .WINDOW_RESIZABLE
    }

    rl.SetConfigFlags(window_flags)
    rl.InitWindow(1440, 720, "Inventory System")

    style.icons = ui.LoadImages()
    appIcon := rl.LoadImageFromTexture(style.icons[ui.Icons.app_icon])
    rl.ImageFormat(&appIcon, rl.PixelFormat.UNCOMPRESSED_R8G8B8A8)
    rl.SetWindowIcon(appIcon)

    util.SetDarkTitlebar()
    rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
    rl.SetExitKey(nil)

    style.colors = ui.LoadColorPalette()
    style.fonts = ui.LoadFont()
    defer ui.FreeFont(style.fonts)
    defer ui.FreeImages(style.icons)

    for !rl.WindowShouldClose()
    {
        free_all(context.temp_allocator)
        //rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
        st.UpdateWindowState(&state)
        
        #partial switch state.page {
        case .Inventory:
            app.InputMoveItem(&state,
            items.backpack,
            style.grid.origin_x,
            style.grid.origin_y,
            style.grid.cell_size)
        case .Character:
            app.InputCharacter(&state, &style)
        case .Debug, .Catalog:
        }

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        v.DrawUI(&state, &style, items.backpack)

        rl.EndDrawing()
    }
}