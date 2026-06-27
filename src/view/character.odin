package view

import rl "vendor:raylib"
import ui "../ui"
import st "../core/state"
import inv "../core/inventory"
import str "core:strings"
import fmt "core:fmt"

DrawCharacter :: proc(state: ^st.state, style: ^ui.style) {
    char := state.character
    if char == nil {
        return
    }

    header_height: f32 = 34
    top_margin := header_height + 10

    centerX := state.window.width / 2 + 100 // Shifted right to make room for list
    centerY := (state.window.height + top_margin) / 2

    // Draw Character Name centered above avatar
    name_str := str.clone_to_cstring(char.name, context.temp_allocator)
    name_width := f32(rl.MeasureTextEx(style.fonts.bold[ui.font_size.title], name_str, f32(ui.font_size.title), 2).x)
    rl.DrawTextEx(style.fonts.bold[ui.font_size.title], name_str, {centerX - name_width / 2, top_margin}, f32(ui.font_size.title), 2, style.colors.text)

    // Collect all items from all containers
    all_items := inv.GetAllCharacterItems(char)

    // Draw Item List on the left
    list_x: f32 = 50
    list_y: f32 = top_margin + 80
    item_height: f32 = 35
    list_width: f32 = 250

    rl.DrawTextEx(style.fonts.semibold[ui.font_size.header], "Container Items", {list_x, list_y - 30}, f32(ui.font_size.header), 1, style.colors.text)

    for item, i in all_items {
        item_rect := rl.Rectangle{list_x, list_y + f32(i) * (item_height + 5), list_width, item_height}
        
        bgColor := style.colors.surface
        if item.grabbed {
            bgColor.a = 128
        }
        
        rl.DrawRectangleRec(item_rect, bgColor)
        rl.DrawRectangleLinesEx(item_rect, 1, style.colors.secondary)
        
        item_name := str.clone_to_cstring(item.definition.name, context.temp_allocator)
        rl.DrawTextEx(style.fonts.regular[ui.font_size.default], item_name, {item_rect.x + 10, item_rect.y + 10}, f32(ui.font_size.default), 1, style.colors.text)
    }

    // Center of the screen for the character avatar
    // centerX and centerY are already defined above
    
    // Draw Character Avatar placeholder
    avatar_width: f32 = 200
    avatar_height: f32 = 400
    avatar_rect := rl.Rectangle{centerX - avatar_width / 2, centerY - avatar_height / 2, avatar_width, avatar_height}
    
    // Draw avatar icon
    icon := style.icons[ui.Icons.character_user]
    icon_pos := rl.Vector2{
        avatar_rect.x + (avatar_rect.width - f32(icon.width)) / 2,
        avatar_rect.y + 50,
    }
    rl.DrawTextureV(icon, icon_pos, rl.WHITE)
    rl.DrawRectangleLinesEx(avatar_rect, 2, style.colors.primary)

    // Define slot positions relative to avatar
    slot_size: f32 = 100
    spacing: f32 = 20

    // Left column
    draw_slot(.Back, {avatar_rect.x - slot_size - spacing, avatar_rect.y}, state, style)
    draw_slot(.Armor, {avatar_rect.x - slot_size - spacing, avatar_rect.y + slot_size + spacing}, state, style)
    
    // Right column
    draw_slot(.Backpack, {avatar_rect.x + avatar_rect.width + spacing, avatar_rect.y}, state, style)
    draw_slot(.Belt, {avatar_rect.x + avatar_rect.width + spacing, avatar_rect.y + slot_size + spacing}, state, style)
    draw_slot(.Holster, {avatar_rect.x + avatar_rect.width + spacing, avatar_rect.y + (slot_size + spacing) * 2}, state, style)

    // Draw Dragged Item Ghost if applicable
    if state.grab.is_dragging && state.grab.dragged_item != nil {
        item := state.grab.dragged_item
        rl.DrawRectangle(i32(state.ghost.unsnapped_x), i32(state.ghost.unsnapped_y), i32(list_width), i32(item_height), {255, 255, 255, 128})
        rl.DrawTextEx(style.fonts.regular[ui.font_size.default], str.clone_to_cstring(item.definition.name, context.temp_allocator), {state.ghost.unsnapped_x + 10, state.ghost.unsnapped_y + 10}, f32(ui.font_size.default), 1, rl.BLACK)
    }
}

draw_slot :: proc(slot: inv.EquipmentSlot, pos: rl.Vector2, state: ^st.state, style: ^ui.style) {
    slot_size: f32 = 100
    rect := rl.Rectangle{pos.x, pos.y, slot_size, slot_size}
    
    // Background
    rl.DrawRectangleRec(rect, style.colors.surface)
    rl.DrawRectangleLinesEx(rect, 1, style.colors.secondary)
    
    // Label
    slot_name := fmt.tprintf("%v", slot)
    slot_name_cstr := str.clone_to_cstring(slot_name, context.temp_allocator)
    rl.DrawTextEx(style.fonts.regular[ui.font_size.caption], slot_name_cstr, {pos.x + 5, pos.y + 5}, f32(ui.font_size.caption), 1, style.colors.text)
    
    if item, ok := state.character.equipment.slots[slot]; ok && item != nil {
        rl.DrawRectangleLinesEx(rect, 2, style.colors.primary)
        
        // Show item name
        item_name_cstr := str.clone_to_cstring(item.definition.name, context.temp_allocator)
        rl.DrawTextEx(style.fonts.semibold[ui.font_size.label], item_name_cstr, {pos.x + 5, pos.y + 25}, f32(ui.font_size.label), 1, style.colors.success)

        if container_data, is_container := item.definition.data.(inv.ContainerData); is_container {
             // Show number of items if it's a container
            item_count := len(container_data.storage.items)
            count_str := fmt.tprintf("Items: %d", item_count)
            count_cstr := str.clone_to_cstring(count_str, context.temp_allocator)
            rl.DrawTextEx(style.fonts.regular[ui.font_size.caption], count_cstr, {pos.x + 5, pos.y + 80}, f32(ui.font_size.caption), 1, style.colors.text)
        }
    } else {
        rl.DrawTextEx(style.fonts.regular[ui.font_size.label], "EMPTY", {pos.x + slot_size/2 - 20, pos.y + slot_size/2 - 7}, f32(ui.font_size.label), 1, style.colors.secondary)
    }
}
