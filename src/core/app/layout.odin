package app

import rl "vendor:raylib"
import inv "../inventory"
import st "../state"

GridLocation :: struct {
    item: ^inv.ItemInstance,
    origin: rl.Vector2,
}

SLOT_SIZE :: 100
SPACING :: 20
AVATAR_WIDTH :: 200
AVATAR_HEIGHT :: 400
GRID_CHAR_SPACING :: 50
CHAR_PAGE_GRID_START_Y :: 100
CHAR_BLOCK_WIDTH :: SLOT_SIZE + SPACING + AVATAR_WIDTH + SPACING + SLOT_SIZE

GetCharacterPageTotalWidth :: proc(char: ^inv.Character, cell_size: f32) -> f32 {
    max_grid_w := GetMaxGridWidth(char, cell_size)
    if max_grid_w <= 0 do return CHAR_BLOCK_WIDTH
    return max_grid_w + GRID_CHAR_SPACING + CHAR_BLOCK_WIDTH
}

GetMaxGridWidth :: proc(char: ^inv.Character, cell_size: f32) -> f32 {
    max_w: f32 = 0
    for _, item in char.equipment.slots {
        if item == nil do continue

        container_data, ok := item.definition.data.(inv.ContainerData)
        if !ok do continue

        storage, is_grid := container_data.storage.storage.(inv.ContainerGrid)
        if !is_grid do continue

        w := f32(storage.width) * cell_size
        if w > max_w do max_w = w
    }
    return max_w
}

CharacterPageLayoutInfo :: struct {
    grid_start_x: f32,
    grid_start_y: f32,
    avatarCenterX: f32,
    char_start_x: f32,
}

GetCharacterPageLayoutInfo :: proc(state: ^st.state, cell_size: f32) -> CharacterPageLayoutInfo {
    char := state.character
    if char == nil do return {}

    grid_start_x: f32 = 50
    grid_start_y: f32 = CHAR_PAGE_GRID_START_Y
    avatarCenterX := f32(state.window.width) / 2
    char_start_x := f32(i32(avatarCenterX - CHAR_BLOCK_WIDTH / 2))

    return {grid_start_x, grid_start_y, avatarCenterX, char_start_x}
}

GetCharacterGridLocations :: proc(char: ^inv.Character, start_y: f32, cell_size: f32, start_x: f32) -> [dynamic]GridLocation {
    locs := make([dynamic]GridLocation, context.temp_allocator)
    current_y: f32 = start_y
    priority_slots := []inv.EquipmentSlot{.Backpack, .Belt}

    for slot in priority_slots {
        item, ok := char.equipment.slots[slot]
        if !ok || item == nil do continue

        _, is_container := item.definition.data.(inv.ContainerData)
        if !is_container do continue

        append(&locs, GridLocation{item, {start_x, current_y}})
        current_y += GetItemGridHeight(item, cell_size) + 60
    }

    for slot, item in char.equipment.slots {
        if slot == .Backpack || slot == .Belt || item == nil do continue

        _, ok := item.definition.data.(inv.ContainerData)
        if !ok do continue

        append(&locs, GridLocation{item, {start_x, current_y}})
        current_y += GetItemGridHeight(item, cell_size) + 60
    }
    return locs
}

GetItemGridHeight :: proc(item: ^inv.ItemInstance, cell_size: f32) -> f32 {
    container_data := item.definition.data.(inv.ContainerData)
    storage, ok := container_data.storage.storage.(inv.ContainerGrid)
    if !ok do return 0
    return f32(storage.height) * cell_size
}

GetCharacterSlotRects :: proc(state: ^st.state, centerX: f32, topY: f32) -> map[inv.EquipmentSlot]rl.Rectangle {
    avatar_rect := rl.Rectangle{f32(i32(centerX - AVATAR_WIDTH / 2)), f32(i32(topY)), AVATAR_WIDTH, AVATAR_HEIGHT}

    slots := make(map[inv.EquipmentSlot]rl.Rectangle, context.temp_allocator)
    slots[.Back] = {avatar_rect.x - SLOT_SIZE - SPACING, avatar_rect.y, SLOT_SIZE, SLOT_SIZE}
    slots[.Armor] = {avatar_rect.x - SLOT_SIZE - SPACING, avatar_rect.y + SLOT_SIZE + SPACING, SLOT_SIZE, SLOT_SIZE}
    slots[.Backpack] = {avatar_rect.x + avatar_rect.width + SPACING, avatar_rect.y, SLOT_SIZE, SLOT_SIZE}
    slots[.Belt] = {avatar_rect.x + avatar_rect.width + SPACING, avatar_rect.y + SLOT_SIZE + SPACING, SLOT_SIZE, SLOT_SIZE}
    slots[.Holster] = {avatar_rect.x + avatar_rect.width + SPACING, avatar_rect.y + (SLOT_SIZE + SPACING) * 2, SLOT_SIZE, SLOT_SIZE}

    return slots
}
