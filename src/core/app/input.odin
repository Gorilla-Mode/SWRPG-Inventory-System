package app

import inv "../inventory"
import rl  "vendor:raylib"
import ui "../../ui"
import st "../state"

InputMoveItem :: proc(state: ^st.State, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	if state.grab.is_dragging {
		HandleDragging(state, container, origin_x, origin_y, cell_size)
		return
	}

	HandleHover(state, container, origin_x, origin_y, cell_size)
}

HandleHover :: proc(state: ^st.State, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	item := GetItemAtMousePos(container, origin_x, origin_y, cell_size)
	if item == nil do return

	if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
		StartDragging(state, item, origin_x, origin_y, cell_size)
		return
	}

	if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
		if !inv.ContainerGridCanRotateItem(container, item) do return

		mouse_pos := rl.GetMousePosition()
		gx := i16((mouse_pos.x - origin_x) / cell_size)
		gy := i16((mouse_pos.y - origin_y) / cell_size)

		lx := gx - item.pos_x
		ly := gy - item.pos_y

		h := item.definition.height

		new_lx, new_ly: i16
		if !item.rotated {
			new_lx = h - 1 - ly
			new_ly = lx
		} else {
			new_lx = ly
			new_ly = h - 1 - lx
		}

		new_pos_x := gx - new_lx
		new_pos_y := gy - new_ly

		if inv.ContainerGridCanPlaceAt(container, item.definition, new_pos_x, new_pos_y, item.id, !item.rotated) {
			item.pos_x = new_pos_x
			item.pos_y = new_pos_y
			item.rotated = !item.rotated
		}
	}
}

HandleDragging :: proc(state: ^st.State, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	item := state.grab.dragged_item
	if !rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
		DropItem(state, container)
		return
	}

	if rl.IsKeyPressed(rl.KeyboardKey.SPACE) {
		if !inv.ContainerGridCanRotateItem(container, item) do return

		h := f32(item.definition.height)
		new_offset_x, new_offset_y: f32
		if !state.ghost.rotated {
			new_offset_x = h * cell_size - state.grab.offset_y
			new_offset_y = state.grab.offset_x
		} else {
			new_offset_x = state.grab.offset_y
			new_offset_y = h * cell_size - state.grab.offset_x
		}

		state.grab.offset_x = new_offset_x
		state.grab.offset_y = new_offset_y
		state.ghost.rotated = !state.ghost.rotated
	}

	mouse_pos := rl.GetMousePosition()
	state.ghost.unsnapped_x = mouse_pos.x - state.grab.offset_x
	state.ghost.unsnapped_y = mouse_pos.y - state.grab.offset_y
	state.ghost.pos_x = i16((state.ghost.unsnapped_x - origin_x + cell_size / 2) / cell_size)
	state.ghost.pos_y = i16((state.ghost.unsnapped_y - origin_y + cell_size / 2) / cell_size)

	state.ghost.valid = inv.ContainerGridCanPlaceAt(container, item.definition, state.ghost.pos_x, state.ghost.pos_y, item.id, state.ghost.rotated)
}

StartDragging :: proc(state: ^st.State, item: ^inv.ItemInstance, origin_x, origin_y, cell_size: f32) {
	mouse_pos := rl.GetMousePosition()
	state.grab.is_dragging = true
	state.grab.dragged_item = item
	item.grabbed = true
	
	item_screen_x := origin_x + f32(item.pos_x) * cell_size
	item_screen_y := origin_y + f32(item.pos_y) * cell_size
	
	state.grab.offset_x = mouse_pos.x - item_screen_x
	state.grab.offset_y = mouse_pos.y - item_screen_y
	state.ghost.pos_x = item.pos_x
	state.ghost.pos_y = item.pos_y
	state.ghost.unsnapped_x = item_screen_x
	state.ghost.unsnapped_y = item_screen_y
	state.ghost.rotated = item.rotated
	state.ghost.valid = true
}

DropItem :: proc(state: ^st.State, container: ^inv.Container) {
	item := state.grab.dragged_item
	item.grabbed = false
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

CheckCollisonItemCard :: proc(state: ^st.State, style: ^ui.style) -> bool{
	return (rl.CheckCollisionPointRec(rl.GetMousePosition(),
	inv.GetItemCardRect(f32(state.grab.selected_item.pos_x),
	f32(state.grab.selected_item.pos_y),
	style)))
}

ShowItemCard :: proc(container: ^inv.Container, style: ^ui.style, state: ^st.State) -> bool {
	hoveredItem := GetItemAtMousePos(container, style.grid.origin_x, style.grid.origin_y, style.grid.cell_size)
	if hoveredItem != nil && rl.IsMouseButtonPressed(rl.MouseButton.RIGHT){
		state.grab.selected_item = hoveredItem

		return true
	}
	return false
}

HideItemCard :: proc(container: ^inv.Container, style: ^ui.style, state: ^st.State){
	if (rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && !CheckCollisonItemCard(state, style)) {
		state.grab.selected_item = nil
	}
}