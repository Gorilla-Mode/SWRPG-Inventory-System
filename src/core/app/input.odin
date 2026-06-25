package app

import inv "../inventory"
import rl  "vendor:raylib"

InputMoveItem :: proc(state: ^State, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	if state.grab.is_dragging {
		HandleDragging(state, container, origin_x, origin_y, cell_size)
		return
	}

	HandleHover(state, container, origin_x, origin_y, cell_size)
}

HandleHover :: proc(state: ^State, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	item := GetItemAtMousePos(container, origin_x, origin_y, cell_size)
	if item == nil do return

	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		StartDragging(state, item, origin_x, origin_y, cell_size)
	} 
}

HandleDragging :: proc(state: ^State, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	item := state.grab.dragged_item
	if !rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
		DropItem(state, container)
		return
	}

	mouse_pos := rl.GetMousePosition()
	state.ghost.pos_x = i16((mouse_pos.x - origin_x - state.grab.offset_x + cell_size / 2) / cell_size)
	state.ghost.pos_y = i16((mouse_pos.y - origin_y - state.grab.offset_y + cell_size / 2) / cell_size)

	if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
		state.ghost.rotated = !state.ghost.rotated
	}

	state.ghost.valid = inv.ContainerGridCanPlaceAt(container, item.definition, state.ghost.pos_x, state.ghost.pos_y, item.id, state.ghost.rotated)
}

StartDragging :: proc(state: ^State, item: ^inv.ItemInstance, origin_x, origin_y, cell_size: f32) {
	mouse_pos := rl.GetMousePosition()
	state.grab.is_dragging = true
	state.grab.dragged_item = item
	
	item_screen_x := origin_x + f32(item.pos_x) * cell_size
	item_screen_y := origin_y + f32(item.pos_y) * cell_size
	
	state.grab.offset_x = mouse_pos.x - item_screen_x
	state.grab.offset_y = mouse_pos.y - item_screen_y
	state.ghost.pos_x = item.pos_x
	state.ghost.pos_y = item.pos_y
	state.ghost.rotated = item.rotated
	state.ghost.valid = true
}

DropItem :: proc(state: ^State, container: ^inv.Container) {
	item := state.grab.dragged_item
	if state.ghost.valid {
		item.pos_x = state.ghost.pos_x
		item.pos_y = state.ghost.pos_y
		item.rotated = state.ghost.rotated
	}
	state.grab.is_dragging = false
	state.grab.dragged_item = nil
}

GetItemAtMousePos :: proc(container: ^inv.Container, origin_x, origin_y, cell_size: f32) -> ^inv.ItemInstance {
	mouse_pos := rl.GetMousePosition()
	for item in container.items {
		bounds := inv.GetBounds(item)
		
		item_screen_x := origin_x + f32(bounds.pos_x) * cell_size
		item_screen_y := origin_y + f32(bounds.pos_y) * cell_size
		item_screen_w := f32(bounds.width) * cell_size
		item_screen_h := f32(bounds.height) * cell_size

		if mouse_pos.x >= item_screen_x && mouse_pos.x < item_screen_x + item_screen_w &&
		   mouse_pos.y >= item_screen_y && mouse_pos.y < item_screen_y + item_screen_h {
			return item
		}
	}
	return nil
}