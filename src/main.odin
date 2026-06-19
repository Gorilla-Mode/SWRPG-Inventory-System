package main

import rl "vendor:raylib"
import util "utils"
import ui "ui"
import inv "core/inventory"
import str "core:strings"

window_width: i32 = 1280
window_height: i32 = 720

State :: struct{
    InventoryGrid: string
}

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
    defer delete(images)
    rl.SetWindowIcon(images[ui.icons.app_icon])

    fnt := ui.LoadFont()
    defer ui.FreeFont(fnt)

    rl.SetTargetFPS(60)
    rl.SetExitKey(nil)

    state := State{}
    items := inv.TestItem()
    inv.TestInvGrid(items.backpack, items.sword, items.rifle, items.sword_instance, items.rifle_instance)
    state.InventoryGrid = inv.ContainerToString(items.backpack)

    for !rl.WindowShouldClose()
    {
        if rl.IsKeyPressed(rl.KeyboardKey.RIGHT)
        {
            if inv.ContainerCanPlaceAt(items.backpack,
            items.rifle_instance.definition,
            items.rifle_instance.pos_x + 1,
            items.rifle_instance.pos_y,
            items.rifle_instance.id)
            {
                items.rifle_instance.pos_x += 1
                state.InventoryGrid = inv.ContainerToString(items.backpack)
            }
        }

        if rl.IsKeyPressed(rl.KeyboardKey.LEFT)
        {
            if inv.ContainerCanPlaceAt(items.backpack,
            items.rifle_instance.definition,
            items.rifle_instance.pos_x - 1,
            items.rifle_instance.pos_y,
            items.rifle_instance.id)
            {
                items.rifle_instance.pos_x -= 1
                state.InventoryGrid = inv.ContainerToString(items.backpack)
            }
        }

        if rl.IsKeyPressed(rl.KeyboardKey.UP)
        {
            if inv.ContainerCanPlaceAt(items.backpack,
            items.rifle_instance.definition,
            items.rifle_instance.pos_x,
            items.rifle_instance.pos_y - 1,
            items.rifle_instance.id)
            {
                items.rifle_instance.pos_y -= 1
                state.InventoryGrid = inv.ContainerToString(items.backpack)
            }
        }

        if rl.IsKeyDown(rl.KeyboardKey.DOWN)
        {
            if inv.ContainerCanPlaceAt(items.backpack,
            items.rifle_instance.definition,
            items.rifle_instance.pos_x,
            items.rifle_instance.pos_y + 1,
            items.rifle_instance.id)
            {
                items.rifle_instance.pos_y += 1
                state.InventoryGrid = inv.ContainerToString(items.backpack)
            }
        }

        grid := str.clone_to_cstring(state.InventoryGrid, context.allocator)
        defer delete_cstring(grid)

        rl.BeginDrawing()
        rl.ClearBackground(palette.surface)

        rl.DrawTextEx(fnt.bold[ui.font_size.title],"SWIS", {20, 5}, f32(ui.font_size.title), 0, palette.text)
        ui.DrawPalette(palette, offset_y = 34)
        rl.DrawTextEx(fnt.semibold[ui.font_size.header], grid, {20, 34 + 100 + 60}, f32(ui.font_size.header), 0, palette.text)

        rl.EndDrawing()
    }
}