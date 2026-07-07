package view

import rl "vendor:raylib"
import ui "../ui"
import st "../core/state"
import inv "../core/inventory"
import app "../core/app"
import str "core:strings"

OverlayJob :: struct {
    item: ^inv.ItemInstance,
    x, y: f32,
}

DrawCharacter :: proc(state: ^st.state, style: ^ui.style) {
    char := state.character
    if char == nil do return

    layout_info := app.GetCharacterPageLayoutInfo(state, style.grid.cell_size)

    DrawCharacterHeader(char, layout_info.center.center_x - (app.AVATAR_WIDTH / 2) - app.SPACING - app.SLOT_SIZE, layout_info.top_y, style)
    DrawCharacterAvatar(layout_info.center.center_x, layout_info.top_y + app.AVATAR_HEIGHT / 2, style)

    slots := app.GetCharacterSlotRects(state, layout_info.center.start_x, layout_info.top_y)
    for slot, rect in slots {
        DrawSlot(slot, {rect.x, rect.y}, state, style)
    }

    grid_locs := app.GetCharacterGridLocations(char, layout_info.top_y, style.grid.cell_size, layout_info.left.origin_x + app.PADDING)
    DrawCharacterGrids(state, grid_locs, style)

    DrawStats(char, &layout_info, style)

    if state.grab.is_dragging && state.grab.dragged_item != nil {
        DrawCharacterGhost(state, grid_locs, style)
    }
}

DrawCharacterHeader :: proc(char: ^inv.Character, startX: f32, topY: f32, style: ^ui.style) {
    name_str := str.clone_to_cstring(char.name, context.temp_allocator)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header], name_str, ui.SnapVector2({startX, topY - f32(ui.font_size.header) - 2}), f32(ui.font_size.header), 2, style.colors.text)
}

DrawCharacterGrids :: proc(state: ^st.state, grid_locs: [dynamic]app.GridLocation, style: ^ui.style,) {
    overlay_jobs: [dynamic]OverlayJob
    defer delete(overlay_jobs)

    for loc in grid_locs {
        inv.DrawContainerGrid(loc.item.definition, loc.item, loc.origin.x, loc.origin.y, style.grid.cell_size, style)

        should_show := app.ShowItemCard(loc.item, loc.origin.x, loc.origin.y, style, state) ||
        state.grab.selected_item != nil

        if should_show {
            append(&overlay_jobs, OverlayJob{ item = loc.item, x = loc.origin.x, y = loc.origin.y})
        }
    }

    for job in overlay_jobs {
        DrawItemCard(job.item, job.x, job.y, state, style)
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

        if !rl.CheckCollisionPointRec(mouse_pos, rect) do continue

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

DrawSlot :: proc(slot: inv.EquipmentSlot, pos: rl.Vector2, state: ^st.state, style: ^ui.style) {
    rect := rl.Rectangle{f32(i32(pos.x)), f32(i32(pos.y)), app.SLOT_SIZE, app.SLOT_SIZE}
    item, ok := state.character.equipment.slots[slot]
    slotText : cstring = str.clone_to_cstring(inv.EquipmentSlotString[slot], context.temp_allocator)
    itemText : cstring = ok ? str.clone_to_cstring(state.character.equipment.slots[slot].definition.name, context.temp_allocator) : str.clone_to_cstring("EMPTY", context.temp_allocator)
    itemTextColor := ok ? style.colors.success : style.colors.text
    fontSize := ui.font_size.label
    font:= style.fonts.regular[fontSize]
    size := rl.MeasureTextEx(font, itemText, f32(fontSize), 0)
    itemTextPos := ok ? ui.SnapVector2({pos.x + 4, pos.y + size.y + 5 }) : ui.SnapVector2({pos.x + app.SLOT_SIZE * 0.5 - size.x * 0.5, pos.y + app.SLOT_SIZE * 0.5 - size.y * 0.5 })
    slotTextPos := ui.SnapVector2({pos.x + 4, pos.y + 5 })

    rl.DrawRectangleRec(rect, style.colors.surface)
    rl.DrawRectangleLinesEx(rect, 2, style.colors.secondary)
    rl.DrawTextEx(font, slotText, slotTextPos, f32(fontSize), 0, style.colors.text)
    rl.DrawTextEx(font, itemText, itemTextPos, f32(fontSize), 0, itemTextColor)

    if !ok do return
    if _, is_container := item.definition.data.(inv.ContainerData); is_container {
        item_data, has_items := item.data.(inv.ContainerInstanceData)
        if !has_items do return

        item_count := len(item_data.items)

        b := str.Builder{}
        str.builder_init(&b, context.temp_allocator)
        str.write_string(&b, "Count: ")
        str.write_int(&b, item_count)
        count_str := str.to_string(b)

        count_cstr := str.clone_to_cstring(count_str, context.temp_allocator)
        rl.DrawTextEx(font, count_cstr, ui.SnapVector2({pos.x + 5, pos.y + app.SLOT_SIZE - 20 }), f32(fontSize), 1, style.colors.text)
    }
}

DrawStats :: proc(char: ^inv.Character, layout: ^app.CharacterPageLayout, style: ^ui.style) {
    rect := rl.Rectangle{layout.right.origin_x, layout.top_y, layout.right.width, f32(rl.GetScreenHeight()) - layout.top_y}
    rect_top : rl.Rectangle = {rect.x, rect.y, rect.width, rect.height / 2}
    rect_bottom : rl.Rectangle = {rect.x, rect.y + rect.height / 2, rect.width, rect.height / 2}

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header],
    "Stat", ui.SnapVector2({layout.right.origin_x, layout.top_y - f32(ui.font_size.header) - 2}),
    f32(ui.font_size.header),
    2,
    style.colors.text)

    rl.DrawRectangleRec(rect, style.colors.secondary)
    rl.DrawRectangleRec(rect_top, style.colors.surface)
    rl.DrawRectangleRec(rect_bottom, style.colors.primary)

    rl.DrawLineEx({ rect.x, rect.y  + 1}, { rect.x, rect.y + rect.height + 1 }, 2, style.colors.primary)
    rl.DrawLineEx({ rect.x - 1, rect.y + 1 }, { rect.x + rect.width + 1, rect.y + 1}, 2, style.colors.primary)
    rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], "Equipped Item", ui.SnapVector2({rect_top.x + 5, rect_top.y + 5}), f32(ui.font_size.label), 2, style.colors.text)

    if char.equipment.slots[.Back] == nil do return
    inv.DrawItem(char.equipment.slots[.Back], rect_top.x + 5, rect_top.y + 30, style.grid.cell_size, style, true)
}