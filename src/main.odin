package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import app "core/app"
import v "view"
import st "core/state"
import t "core:time"
import dbug "core/debug"
import fmt "core:fmt"

main :: proc()
{
    defer rl.CloseWindow()
    defer free_all(context.allocator)
    start := t.now()

    style := ui.style{
        grid = {
            cell_size = 50
        }
    }

    state := st.state{textFields = make(map[st.textField]st.textFieldState)}
    state.ItemDefinitionRegistry = inv.MakeItemDefinitionRegistry()
    state.ItemInstanceRegistry = inv.MakeItemInstanceRegistry()
    state.debug = true
    state.catalog.sub_category = st.NoSubCategory.None

    inv.TestRegistry(&state.ItemDefinitionRegistry, state.debug)
    items := inv.TestItemInstance(style.grid.cell_size, &state.ItemDefinitionRegistry, &state.ItemInstanceRegistry, state.debug)
    state.character = inv.TestCharacter(items.backpackInstance, &state.ItemDefinitionRegistry, &state.ItemInstanceRegistry, state.debug)
    defer delete(state.textFields)
    defer delete(state.ItemDefinitionRegistry.items)
    defer inv.DeleteItemInstanceRegistry(&state.ItemInstanceRegistry)

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

    dbug.Debug(fmt.tprint("Loaded in:", t.duration_milliseconds(t.since(start)), "Ms"))

    for !rl.WindowShouldClose()
    {
        free_all(context.temp_allocator)
        //rl.SetTargetFPS(rl.GetMonitorRefreshRate(rl.GetCurrentMonitor()))
        st.UpdateWindowState(&state)
        
        #partial switch state.page {
        case .Inventory:
            app.InputMoveItem(&state,
            items.backpackInstance,
            style.grid.origin_x,
            style.grid.origin_y,
            style.grid.cell_size)
        case .Character:
            app.InputCharacter(&state, &style)
        case .Debug, .Catalog:
        }

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        v.DrawUI(&state, &style, items.backpackInstance)

        rl.EndDrawing()
    }
}