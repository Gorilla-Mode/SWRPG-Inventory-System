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
    hoveredItem: ^inv.ItemInstance

    for !rl.WindowShouldClose()
    {
        grid_x: f32 = 20
        grid_y: f32 = 34 + 100 + 60
        grid_size: f32 = 50

        app.InputMoveItem(&state,
        items.backpack,
        grid_x,
        grid_y,
        grid_size)

        rl.BeginDrawing()
        rl.ClearBackground(style.colors.surface)

        rl.DrawTextEx(style.fonts.bold[ui.font_size.title],
        "SWIS",
        {20, 5},
        f32(ui.font_size.title),
        0,
        style.colors.text)
        ui.DrawPalette(style.colors, offset_y = 34)

        inv.DrawContainerGrid(items.backpack, grid_x, grid_y, grid_size, &style)

        if state.grab.is_dragging && state.grab.dragged_item != nil {
            if inv.ContainerGridCheckBounds(items.backpack, inv.Rect{
                pos_x = state.ghost.pos_x,
                pos_y = state.ghost.pos_y,
                width = inv.ItemGetWidth(state.grab.dragged_item),
                height = inv.ItemGetHeight(state.grab.dragged_item),
            })
            {
                inv.DrawItemGhost(state.grab.dragged_item,
                f32(state.ghost.pos_x),
                f32(state.ghost.pos_y),
                true,
                state.ghost.rotated,
                state.ghost.valid,
                grid_x,
                grid_y,
                grid_size,
                &style)
            }

            inv.DrawItemGhost(state.grab.dragged_item,
            state.ghost.unsnapped_x,
            state.ghost.unsnapped_y,
            false,
            state.ghost.rotated,
            state.ghost.valid,
            grid_x,
            grid_y,
            grid_size,
            &style)
        }

        if app.GetItemAtMousePos(items.backpack, grid_x, grid_y, grid_size) != nil && rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
            hoveredItem = app.GetItemAtMousePos(items.backpack, grid_x, grid_y, grid_size)
        }

        if hoveredItem != nil {

            inv.DrawItemCard(hoveredItem, f32(hoveredItem.pos_x), f32(hoveredItem.pos_y), grid_x, grid_y, grid_size, &style)
            if rl.IsMouseButtonPressed(rl.MouseButton.MIDDLE) || hoveredItem.grabbed
            {
                hoveredItem = nil
            }
        }

        rl.EndDrawing()
    }
}