package app

import inv "../inventory"
import rl  "vendor:raylib"
import ui "../../ui"
import st "../state"

InputMoveItem :: proc(state: ^st.state, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	if state.grab.is_dragging {
		HandleDragging(state, container, origin_x, origin_y, cell_size)
		return
	}

	HandleHover(state, container, origin_x, origin_y, cell_size)
}

UpdateGhostUnsnapped :: proc(state: ^st.state) {
    mouse_pos := rl.GetMousePosition()
    state.ghost.unsnapped_x = mouse_pos.x - state.grab.offset_x
    state.ghost.unsnapped_y = mouse_pos.y - state.grab.offset_y
}

HandleRotationInput :: proc(state: ^st.state, cell_size: f32) {
    if !rl.IsKeyPressed(rl.KeyboardKey.SPACE) do return

    item := state.grab.dragged_item
    if item == nil do return
    if item.definition.width == item.definition.height do return

    current_width: f32
    current_height: f32

    if state.ghost.rotated {
        current_width = f32(item.definition.height) * cell_size
        current_height = f32(item.definition.width) * cell_size
    } else {
        current_width = f32(item.definition.width) * cell_size
        current_height = f32(item.definition.height) * cell_size
    }

    old_x := state.grab.offset_x
    old_y := state.grab.offset_y

    if state.ghost.rotated {
        state.grab.offset_x = old_y
        state.grab.offset_y = current_width - old_x
    } else {
        state.grab.offset_x = current_height - old_y
        state.grab.offset_y = old_x
    }

    state.ghost.rotated = !state.ghost.rotated
}

InputCharacter :: proc(state: ^st.state, style: ^ui.style) {
    char := state.character
    if char == nil do return

    cell_size := style.grid.cell_size
    layout_info := GetCharacterPageLayoutInfo(state, cell_size)
    grid_locs := GetCharacterGridLocations(char, layout_info.grid_start_y, cell_size, layout_info.grid_start_x)
    slots := GetCharacterSlotRects(state, layout_info.avatarCenterX, layout_info.grid_start_y)

    if state.grab.is_dragging {
        HandleCharacterDragging(state, char, cell_size, slots, grid_locs)
    } else {
        HandleCharacterInteraction(state, char, cell_size, slots, grid_locs)
    }
}

HandleCharacterDragging :: proc(state: ^st.state, char: ^inv.Character, cell_size: f32, slots: map[inv.EquipmentSlot]rl.Rectangle, grid_locs: [dynamic]GridLocation) {
    UpdateGhostUnsnapped(state)
    state.ghost.valid = false

    HandleRotationInput(state, cell_size)

    mouse_pos := rl.GetMousePosition()

    // 1. Check Slots
    for slot, rect in slots {
        if rl.CheckCollisionPointRec(mouse_pos, rect) {
            state.ghost.valid = true
            if rl.IsMouseButtonReleased(.LEFT) {
                inv.EquipItem(char, slot, state.grab.dragged_item)
                StopDragging(state)
            }
            return
        }
    }

    // 2. Check Grids
    for loc in grid_locs {
        container := loc.item.definition.data.(inv.ContainerData).storage
        grid := container.storage.(inv.ContainerGrid)
        rect := rl.Rectangle{loc.origin.x, loc.origin.y, f32(grid.width) * cell_size, f32(grid.height) * cell_size}
        
        if rl.CheckCollisionPointRec(mouse_pos, rect) {
            state.ghost.pos_x = i16((state.ghost.unsnapped_x - loc.origin.x + cell_size / 2) / cell_size)
            state.ghost.pos_y = i16((state.ghost.unsnapped_y - loc.origin.y + cell_size / 2) / cell_size)
            state.ghost.valid = inv.ContainerGridCanPlaceAt(container, state.grab.dragged_item.definition, state.ghost.pos_x, state.ghost.pos_y, state.grab.dragged_item.id, state.ghost.rotated)
            
            if rl.IsMouseButtonReleased(.LEFT) && state.ghost.valid {
                inv.MoveItemToContainer(char, container, state.grab.dragged_item, state.ghost.pos_x, state.ghost.pos_y, state.ghost.rotated)
                StopDragging(state)
            }
            return
        }
    }

    if rl.IsMouseButtonReleased(.LEFT) {
        StopDragging(state)
    }
}

HandleCharacterInteraction :: proc(state: ^st.state, char: ^inv.Character, cell_size: f32, slots: map[inv.EquipmentSlot]rl.Rectangle, grid_locs: [dynamic]GridLocation) {
    mouse_pos := rl.GetMousePosition()

    for loc in grid_locs {
        container := loc.item.definition.data.(inv.ContainerData).storage
        item := GetItemAtMousePos(container, loc.origin.x, loc.origin.y, cell_size)
        if item != nil && rl.IsMouseButtonPressed(.LEFT) {
            StartDragging(state, item, loc.origin.x, loc.origin.y, cell_size)
            return
        }
    }

    for slot, rect in slots {
        if item, ok := char.equipment.slots[slot]; ok && item != nil {
            if rl.IsMouseButtonPressed(.LEFT) && rl.CheckCollisionPointRec(mouse_pos, rect) {
                StartDraggingAtSlot(state, item, rect, cell_size)
                return
            }
        }
    }
}

StartDraggingAtSlot :: proc(state: ^st.state, item: ^inv.ItemInstance, rect: rl.Rectangle, cell_size: f32) {
    mouse_pos := rl.GetMousePosition()
    state.grab.is_dragging = true
    state.grab.dragged_item = item
    item.grabbed = true
    state.grab.offset_x = f32(inv.ItemGetWidth(item)) * cell_size / 2
    state.grab.offset_y = f32(inv.ItemGetHeight(item)) * cell_size / 2
    state.ghost.unsnapped_x = mouse_pos.x - state.grab.offset_x
    state.ghost.unsnapped_y = mouse_pos.y - state.grab.offset_y
    state.ghost.rotated = item.rotated
    state.ghost.valid = true
}

StopDragging :: proc(state: ^st.state) {
    if state.grab.dragged_item != nil {
        state.grab.dragged_item.grabbed = false
    }
    state.grab.is_dragging = false
    state.grab.dragged_item = nil
}

CalculateRotatedPosition :: proc(item: ^inv.ItemInstance, gx, gy: i16) -> (i16, i16) {
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

    return gx - new_lx, gy - new_ly
}

HandleHover :: proc(state: ^st.state, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
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

		new_pos_x, new_pos_y := CalculateRotatedPosition(item, gx, gy)

		if inv.ContainerGridCanPlaceAt(container, item.definition, new_pos_x, new_pos_y, item.id, !item.rotated) {
			item.pos_x = new_pos_x
			item.pos_y = new_pos_y
			item.rotated = !item.rotated
		}
	}
}

HandleDragging :: proc(state: ^st.state, container: ^inv.Container, origin_x, origin_y, cell_size: f32) {
	item := state.grab.dragged_item
	if !rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
		DropItem(state, container)
		return
	}

	HandleRotationInput(state, cell_size)

	UpdateGhostUnsnapped(state)
	state.ghost.pos_x = i16((state.ghost.unsnapped_x - origin_x + cell_size / 2) / cell_size)
	state.ghost.pos_y = i16((state.ghost.unsnapped_y - origin_y + cell_size / 2) / cell_size)

	state.ghost.valid = inv.ContainerGridCanPlaceAt(container, item.definition, state.ghost.pos_x, state.ghost.pos_y, item.id, state.ghost.rotated)
}

StartDragging :: proc(state: ^st.state, item: ^inv.ItemInstance, origin_x, origin_y, cell_size: f32) {
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

DropItem :: proc(state: ^st.state, container: ^inv.Container) {
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

CheckCollisonItemCard :: proc(state: ^st.state, style: ^ui.style, origin_x, origin_y: f32) -> bool{
	return (rl.CheckCollisionPointRec(rl.GetMousePosition(),
	inv.GetItemCardRect(f32(state.grab.selected_item.pos_x),
	f32(state.grab.selected_item.pos_y),
	origin_x, origin_y,
	style)))
}

ShowItemCard :: proc(container: ^inv.Container, origin_x, origin_y: f32, style: ^ui.style, state: ^st.state) -> bool {
	hoveredItem := GetItemAtMousePos(container, origin_x, origin_y, style.grid.cell_size)
	if hoveredItem != nil && rl.IsMouseButtonPressed(rl.MouseButton.RIGHT){
		state.grab.selected_item = hoveredItem

		return true
	}
	return false
}

HideItemCard :: proc(container: ^inv.Container, origin_x, origin_y: f32, style: ^ui.style, state: ^st.state){
	if state.grab.selected_item == nil do return

	is_in_container := false
	for item in container.items {
		if item == state.grab.selected_item {
			is_in_container = true
			break
		}
	}
	if !is_in_container do return

	if (rl.IsMouseButtonPressed(rl.MouseButton.LEFT) && !CheckCollisonItemCard(state, style, origin_x, origin_y)) {
		state.grab.selected_item = nil
	}
}