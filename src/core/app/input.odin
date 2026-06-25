package app

import inv "../inventory"
import rl  "vendor:raylib"

InputMoveItem :: proc(state: ^State, item: ^inv.ItemInstance, container: ^inv.Container, origin_x, origin_y, cell_size: f32){
    mouse_pos := rl.GetMousePosition()

    item_width := f32(inv.ItemGetWidth(item))
    item_height := f32(inv.ItemGetHeight(item))

    item_screen_x := origin_x + f32(item.pos_x) * cell_size
    item_screen_y := origin_y + f32(item.pos_y) * cell_size
    item_screen_w := item_width * cell_size
    item_screen_h := item_height * cell_size

    if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        if mouse_pos.x >= item_screen_x && mouse_pos.x < item_screen_x + item_screen_w &&
           mouse_pos.y >= item_screen_y && mouse_pos.y < item_screen_y + item_screen_h {
            state.is_dragging = true
            state.grab_offset_x = mouse_pos.x - item_screen_x
            state.grab_offset_y = mouse_pos.y - item_screen_y
            state.ghost_pos_x = item.pos_x
            state.ghost_pos_y = item.pos_y
            state.ghost_rotated = item.rotated
        }
    }

    if state.is_dragging {
        if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
            state.ghost_pos_x = i16((mouse_pos.x - origin_x - state.grab_offset_x + cell_size / 2) / cell_size)
            state.ghost_pos_y = i16((mouse_pos.y - origin_y - state.grab_offset_y + cell_size / 2) / cell_size)

            if rl.IsKeyPressed(rl.KeyboardKey.SPACE){
                state.ghost_rotated = !state.ghost_rotated
            }

            state.ghost_valid = inv.ContainerGridCanPlaceAt(container, item.definition, state.ghost_pos_x, state.ghost_pos_y, item.id, state.ghost_rotated)
        } else {
            if state.ghost_valid {
                item.pos_x = state.ghost_pos_x
                item.pos_y = state.ghost_pos_y
                item.rotated = state.ghost_rotated
                state.InventoryGrid = inv.ContainerToString(container)
            }
            state.is_dragging = false
        }
    } else {
        if rl.IsKeyPressed(rl.KeyboardKey.SPACE){
            if inv.ContainerGridRotateItem(container, item) {
                state.InventoryGrid = inv.ContainerToString(container)
            }
        }
    }
}