package view

import rl "vendor:raylib"
import ui "../ui"
import st "../core/state"
import inv "../core/inventory"
import app "../core/app"
import str "core:strings"
import fmt "core:fmt"

DrawCharacter :: proc(state: ^st.state, style: ^ui.style) {
    char := state.character
    if char == nil do return

    layout_info := app.GetCharacterPageLayoutInfo(state, style.grid.cell_size)
    
    DrawCharacterHeader(char, layout_info.char_start_x, layout_info.grid_start_y, style)
    
    grid_locs := app.GetCharacterGridLocations(char, layout_info.grid_start_y, style.grid.cell_size, layout_info.grid_start_x)
    DrawCharacterGrids(grid_locs, style)

    DrawCharacterAvatar(layout_info.avatarCenterX, layout_info.grid_start_y + app.AVATAR_HEIGHT / 2, style)

    slots := app.GetCharacterSlotRects(state, layout_info.avatarCenterX, layout_info.grid_start_y)
    for slot, rect in slots {
        draw_slot(slot, {rect.x, rect.y}, state, style)
    }

    if state.grab.is_dragging && state.grab.dragged_item != nil {
        DrawCharacterGhost(state, grid_locs, style)
    }
}

DrawCharacterHeader :: proc(char: ^inv.Character, startX: f32, topY: f32, style: ^ui.style) {
    name_str := str.clone_to_cstring(char.name, context.temp_allocator)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header], name_str, ui.SnapVector2({startX, topY - f32(ui.font_size.header) - 5}), f32(ui.font_size.header), 2, style.colors.text)
}

DrawCharacterGrids :: proc(grid_locs: [dynamic]app.GridLocation, style: ^ui.style) {
    for loc in grid_locs {
        inv.DrawContainerGrid(loc.item.definition, loc.origin.x, loc.origin.y, style.grid.cell_size, style)
    }
}

DrawCharacterAvatar :: proc(centerX, centerY: f32, style: ^ui.style) {
    avatar_rect := rl.Rectangle{f32(i32(centerX - app.AVATAR_WIDTH / 2)), f32(i32(centerY - app.AVATAR_HEIGHT / 2)), app.AVATAR_WIDTH, app.AVATAR_HEIGHT}
    
    icon := style.icons[ui.Icons.character_user]
    icon_pos := rl.Vector2{
        avatar_rect.x + f32(i32((avatar_rect.width - f32(icon.width)) / 2)),
        avatar_rect.y + 50,
    }
    rl.DrawTextureV(icon, icon_pos, rl.WHITE)
    rl.DrawRectangleLinesEx(avatar_rect, 2, style.colors.primary)
}

DrawCharacterGhost :: proc(state: ^st.state, grid_locs: [dynamic]app.GridLocation, style: ^ui.style) {
    item := state.grab.dragged_item
    mouse_pos := rl.GetMousePosition()
    cell_size := style.grid.cell_size

    for loc in grid_locs {
        container_data, ok := loc.item.definition.data.(inv.ContainerData)
        if !ok do continue
        
        grid := container_data.storage.storage.(inv.ContainerGrid)
        rect := rl.Rectangle{loc.origin.x, loc.origin.y, f32(grid.width) * cell_size, f32(grid.height) * cell_size}

        if rl.CheckCollisionPointRec(mouse_pos, rect) {
            gw := state.ghost.rotated ? item.definition.height : item.definition.width
            gh := state.ghost.rotated ? item.definition.width : item.definition.height

            if inv.ContainerGridCheckBounds(container_data.storage, inv.Rect{
                pos_x = state.ghost.pos_x,
                pos_y = state.ghost.pos_y,
                width = gw,
                height = gh,
            }) {
                inv.DrawItemGhost(item,
                    f32(state.ghost.pos_x),
                    f32(state.ghost.pos_y),
                    true,
                    state.ghost.rotated,
                    state.ghost.valid,
                    loc.origin.x,
                    loc.origin.y,
                    cell_size,
                    style)
            }
            break
        }
    }

    inv.DrawItemGhost(item,
        state.ghost.unsnapped_x,
        state.ghost.unsnapped_y,
        false,
        state.ghost.rotated,
        state.ghost.valid,
        0, 0,
        style.grid.cell_size,
        style)
}

draw_slot :: proc(slot: inv.EquipmentSlot, pos: rl.Vector2, state: ^st.state, style: ^ui.style) {
    rect := rl.Rectangle{f32(i32(pos.x)), f32(i32(pos.y)), app.SLOT_SIZE, app.SLOT_SIZE}

    rl.DrawRectangleRec(rect, style.colors.surface)
    rl.DrawRectangleLinesEx(rect, 1, style.colors.secondary)

    slot_name := fmt.tprintf("%v", slot)
    slot_name_cstr := str.clone_to_cstring(slot_name, context.temp_allocator)
    rl.DrawTextEx(style.fonts.regular[ui.font_size.caption], slot_name_cstr, ui.SnapVector2({pos.x + 5, pos.y + 5}), f32(ui.font_size.caption), 1, style.colors.text)
    
    if item, ok := state.character.equipment.slots[slot]; ok && item != nil {
        rl.DrawRectangleLinesEx(rect, 2, style.colors.primary)
        
        // Show item name
        item_name_cstr := str.clone_to_cstring(item.definition.name, context.temp_allocator)
        rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], item_name_cstr, ui.SnapVector2({pos.x + 5, pos.y + 25}), f32(ui.font_size.label), 1, style.colors.success)

        if container_data, is_container := item.definition.data.(inv.ContainerData); is_container {
             // Show number of items if it's a container
            item_count := len(container_data.storage.items)
            count_str := fmt.tprintf("Items: %d", item_count)
            count_cstr := str.clone_to_cstring(count_str, context.temp_allocator)
            rl.DrawTextEx(style.fonts.regular[ui.font_size.caption], count_cstr, ui.SnapVector2({pos.x + 5, pos.y + 80}), f32(ui.font_size.caption), 1, style.colors.text)
        }
    } else {
        rl.DrawTextEx(style.fonts.regular[ui.font_size.label], "EMPTY", ui.SnapVector2({pos.x + app.SLOT_SIZE/2 - 20, pos.y + app.SLOT_SIZE/2 - 7}), f32(ui.font_size.label), 1, style.colors.secondary)
    }
}
