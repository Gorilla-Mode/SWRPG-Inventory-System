package app

import inv "../inventory"
import rl  "vendor:raylib"

InputMoveItem :: proc(state: ^State, container: ^inv.Container, origin_x, origin_y, cell_size: f32){
    mouse_pos := rl.GetMousePosition()

    if !state.grab.is_dragging {
        // Detect item under mouse
        item_under_mouse: ^inv.ItemInstance = nil
        for item in container.items {
            item_width := f32(inv.ItemGetWidth(item))
            item_height := f32(inv.ItemGetHeight(item))

            item_screen_x := origin_x + f32(item.pos_x) * cell_size
            item_screen_y := origin_y + f32(item.pos_y) * cell_size
            item_screen_w := item_width * cell_size
            item_screen_h := item_height * cell_size

            if mouse_pos.x >= item_screen_x && mouse_pos.x < item_screen_x + item_screen_w &&
               mouse_pos.y >= item_screen_y && mouse_pos.y < item_screen_y + item_screen_h {
                item_under_mouse = item
                break
            }
        }

        if item_under_mouse != nil {
            if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
                state.grab.is_dragging = true
                state.grab.dragged_item = item_under_mouse
                
                item_screen_x := origin_x + f32(item_under_mouse.pos_x) * cell_size
                item_screen_y := origin_y + f32(item_under_mouse.pos_y) * cell_size
                
                state.grab.offset_x = mouse_pos.x - item_screen_x
                state.grab.offset_y = mouse_pos.y - item_screen_y
                state.ghost.pos_x = item_under_mouse.pos_x
                state.ghost.pos_y = item_under_mouse.pos_y
                state.ghost.rotated = item_under_mouse.rotated
                state.ghost.valid = true
            }

            if rl.IsKeyPressed(rl.KeyboardKey.SPACE){
                if inv.ContainerGridRotateItem(container, item_under_mouse) {
                    state.InventoryGrid = inv.ContainerToString(container)
                }
            }
        }
    } else {
        item := state.grab.dragged_item
        if rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
            state.ghost.pos_x = i16((mouse_pos.x - origin_x - state.grab.offset_x + cell_size / 2) / cell_size)
            state.ghost.pos_y = i16((mouse_pos.y - origin_y - state.grab.offset_y + cell_size / 2) / cell_size)

            if rl.IsKeyPressed(rl.KeyboardKey.SPACE){
                state.ghost.rotated = !state.ghost.rotated
            }

            state.ghost.valid = inv.ContainerGridCanPlaceAt(container, item.definition, state.ghost.pos_x, state.ghost.pos_y, item.id, state.ghost.rotated)
        } else {
            if state.ghost.valid {
                item.pos_x = state.ghost.pos_x
                item.pos_y = state.ghost.pos_y
                item.rotated = state.ghost.rotated
                state.InventoryGrid = inv.ContainerToString(container)
            }
            state.grab.is_dragging = false
            state.grab.dragged_item = nil
        }
    }
}