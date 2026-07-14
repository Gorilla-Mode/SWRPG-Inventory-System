package app

import rl "vendor:raylib"
import inv "../inventory"
import st "../state"
import ui "../../ui"

GridLocation :: struct {
    item: ^inv.ItemInstance,
    origin: rl.Vector2,
}

SLOT_SIZE :: 125
SPACING :: 5
AVATAR_WIDTH :: 200
AVATAR_HEIGHT :: 400

GRID_CHAR_SPACING :: 50
PAGE_STAR_Y :: 2 * ui.HEADER_HEIGHT + 10
CHAR_BLOCK_WIDTH :: SLOT_SIZE + SPACING + AVATAR_WIDTH + SPACING + SLOT_SIZE
PADDING :: 20

PageSection :: struct {
    origin_x: f32,
    center_x: f32,
    width:    f32,
    start_x:  f32,
}

CharacterPageLayout :: struct {
    left:   PageSection,
    center: PageSection,
    right:  PageSection,

    top_y: f32,

    grid_start_x: f32,
}

CatalogPageLayout :: struct {
    left:   PageSection,
    right:  PageSection,

    top_y: f32,
}

GetCatalogPageLayoutInfo :: proc(state: ^st.state, cellSize: f32) -> CatalogPageLayout {
    w := f32(state.window.width)

    left_width  :f32 = 650
    right_width :f32 = w - left_width

    left := PageSection{
        origin_x = 0,
        width = left_width,
        center_x = left_width / 2,
    }

    grid_width := GetMaxGridWidth(state.character, cellSize)
    left.start_x = left.center_x - grid_width / 2

    right := PageSection{
        origin_x = left_width,
        width = right_width,
        center_x = left_width + right_width / 2,
    }

    right.start_x = right.center_x

    return CatalogPageLayout{
        left = left,
        right = right,
        top_y = PAGE_STAR_Y,
    }
}

GetCharacterPageLayoutInfo :: proc(state: ^st.state, cell_size: f32) -> CharacterPageLayout {
    w := f32(state.window.width)
    grid_width := GetMaxGridWidth(state.character, cell_size)
    section_width := w / 3

    left := PageSection{
        origin_x = 0,
        center_x = section_width / 2,
        width = section_width,
    }
    left.start_x = left.center_x - grid_width / 2

    center := PageSection{
        origin_x = section_width,
        center_x = section_width + section_width / 2,
        width = section_width,
    }
    center.start_x = center.center_x

    right := PageSection{
        origin_x = section_width * 2,
        center_x = section_width * 2 + section_width / 2,
        width = section_width,
    }
    right.start_x = right.center_x - grid_width / 2

    return CharacterPageLayout{
        left = left,
        center = center,
        right = right,

        top_y = PAGE_STAR_Y
    }
}

GetCharacterGridLocations :: proc(
char: ^inv.Character,
start_y: f32,
cell_size: f32,
start_x: f32,
) -> [dynamic]GridLocation {

    locs := make([dynamic]GridLocation, context.temp_allocator)
    current_y := start_y

    priority_slots := []inv.EquipmentSlot{
        .Backpack,
        .Belt,
    }

    for slot in priority_slots {
        item, ok := char.equipment.slots[slot]
        if !ok || item == nil do continue

        _, is_container := item.definition.data.(inv.ContainerData)
        if !is_container do continue

        append(&locs, GridLocation{
            item = item,
            origin = {start_x, current_y},
        })

        current_y += GetItemGridHeight(item, cell_size) + cell_size
    }

    for slot, item in char.equipment.slots {
        if slot == .Backpack || slot == .Belt || item == nil do continue

        _, ok := item.definition.data.(inv.ContainerData)
        if !ok do continue

        append(&locs, GridLocation{
            item = item,
            origin = {start_x, current_y},
        })

        current_y += GetItemGridHeight(item, cell_size) + cell_size
    }

    return locs
}

GetItemGridHeight :: proc(item: ^inv.ItemInstance, cell_size: f32) -> f32 {
    container_data := item.definition.data.(inv.ContainerData)

    storage, ok := container_data.containerDef.storage.(inv.ContainerGrid)
    if !ok do return 0

    return f32(storage.height) * cell_size
}

GetCharacterSlotRects :: proc(
state: ^st.state,
center_x: f32,
top_y: f32,
) -> map[inv.EquipmentSlot]rl.Rectangle {

    avatar_rect := rl.Rectangle{
        x = center_x - AVATAR_WIDTH / 2,
        y = top_y,
        width = AVATAR_WIDTH,
        height = AVATAR_HEIGHT,
    }

    slots := make(map[inv.EquipmentSlot]rl.Rectangle, context.temp_allocator)

    slots[.Back] = {
        avatar_rect.x - SLOT_SIZE - SPACING,
        avatar_rect.y,
        SLOT_SIZE,
        SLOT_SIZE,
    }

    slots[.Armor] = {
        avatar_rect.x - SLOT_SIZE - SPACING,
        avatar_rect.y + SLOT_SIZE + SPACING,
        SLOT_SIZE,
        SLOT_SIZE,
    }

    slots[.Backpack] = {
        avatar_rect.x + avatar_rect.width + SPACING,
        avatar_rect.y,
        SLOT_SIZE,
        SLOT_SIZE,
    }

    slots[.Belt] = {
        avatar_rect.x + avatar_rect.width + SPACING,
        avatar_rect.y + SLOT_SIZE + SPACING,
        SLOT_SIZE,
        SLOT_SIZE,
    }

    slots[.Holster] = {
        avatar_rect.x + avatar_rect.width + SPACING,
        avatar_rect.y + (SLOT_SIZE + SPACING) * 2,
        SLOT_SIZE,
        SLOT_SIZE,
    }

    return slots
}

GetMaxGridWidth :: proc(char: ^inv.Character, cell_size: f32) -> f32 {
    max_w: f32 = 0

    for _, item in char.equipment.slots {
        if item == nil do continue

        container_data, ok := item.definition.data.(inv.ContainerData)
        if !ok do continue

        storage, is_grid := container_data.containerDef.storage.(inv.ContainerGrid)
        if !is_grid do continue

        w := f32(storage.width) * cell_size
        if w > max_w do max_w = w
    }

    return max_w
}