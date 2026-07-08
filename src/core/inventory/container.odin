package inventory

import rl "vendor:raylib"

ContainerType :: enum{
    Backpack,
    Belt,
    Clothing,
}

ContainerDefinition :: struct{
    type: ContainerType,
    storage: ContainerStorage,
}

ContainerStorage :: union{
    ContainerGrid,
    ContainerSlot,
    ContainerVolume
}

ContainerGrid :: struct {
    width, height: i16
}

ContainerSlot :: struct {
    slots:          i32,
    occupied_slots: i32,
    item_whitelist: []string,
    tag_whitelist:  []ItemTag
}

ContainerVolume :: struct {
    volume:      i32,
    volume_used: i32
}

Rect :: struct {
    pos_x, pos_y: i16,
    width, height: i16
}

// Dispatch function to determine if an item can be placed in a container, based on the container's storage type
ContainerCanPlace :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool{
    if container == nil do return false

    container_data, ok := container.definition.data.(ContainerData)
    if !ok do return false

    switch _ in container_data.containerDef.storage{
        case ContainerGrid:
            return ContainerCanPlaceGrid(container, item)
        case ContainerSlot:
            return ContainerCanPlaceSlot(container, item)
        case ContainerVolume:
            return ContainerCanPlaceVolume(container, item)
    }
    return false
}

ContainerCanPlaceSlot :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool{
    if container == nil do return false

    container_data, ok := container.definition.data.(ContainerData)
    if !ok {
        return false
    }

    slot, slot_ok := container_data.containerDef.storage.(ContainerSlot)
    if !slot_ok {
        return false
    }

    if slot.slots <= slot.occupied_slots {
        return false
    }

    return true
}

ContainerCanPlaceVolume :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool{
    if container == nil do return false

    container_data, ok := container.definition.data.(ContainerData)
    if !ok {
        return false
    }

    vol, vol_ok := container_data.containerDef.storage.(ContainerVolume)
    if !vol_ok {
        return false
    }

    if vol.volume_used + ItemArea(item.definition) > vol.volume {
        return false
    }
    return true
}

ContainerGridCheckBounds :: proc(container: ^ContainerDefinition, item_bounds: Rect) -> bool{
    grid, ok := container.storage.(ContainerGrid)
    if !ok {
        return false
    }

    if item_bounds.pos_x < 0 || item_bounds.pos_y < 0 {
        return false
    }

    if item_bounds.pos_x + item_bounds.width > grid.width {
        return false
    }

    if item_bounds.pos_y + item_bounds.height > grid.height {
        return false
    }

    return true
}

ContainerCanPlaceGrid :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool{
    if container == nil do return false

    container_data, ok := container.definition.data.(ContainerData)
    if !ok {
        return false
    }

    item_bounds := GetBounds(item)
    if !ContainerGridCheckBounds(&container_data.containerDef, item_bounds) {
        return false
    }

    container_items, items_ok := container.data.(ContainerInstanceData)
    if !items_ok {
        return false
    }

    for existing in container_items.items{
        if existing.id == item.id {
            continue
        }
        existing_item_bounds := GetBounds(existing)
        if ContainerGridRectOverlap( existing_item_bounds.pos_x,
        existing_item_bounds.pos_y,
        existing_item_bounds.width,
        existing_item_bounds.height,
        item_bounds.pos_x,
        item_bounds.pos_y,
        item_bounds.width,
        item_bounds.height,){
            return false
        }
    }
    return true
}

ContainerGridCanPlaceAt :: proc(container: ^ItemInstance,
    Item: ^Item,
    x: i16,
    y: i16,
    id: u64,
    rot: bool
) -> bool{
    temp := ItemInstance{
        definition = Item,
        pos_x = x,
        pos_y = y,
        id = id,
        rotated = rot,
    }

    return ContainerCanPlaceGrid(container, &temp)
}

ContainerGridRectOverlap :: proc(
    ax, ay, aw, ah: i16,
    bx, by, bw, bh: i16,
) -> bool {
    return !(ax + aw <= bx ||
        bx + bw <= ax ||
        ay + ah <= by ||
        by + bh <= ay)
}

ContainerAddItem :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool{
    if ContainerCanPlace(container, item) {
        container_data, ok := container.data.(ContainerInstanceData)
        if !ok {
            return false
        }

        append_elem(&container_data.items, item)
        container.data = container_data
        return true
    }

    return false
}

ContainerGridCanRotateItem :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool {
    if container == nil do return false

    container_data, ok := container.definition.data.(ContainerData)
    if !ok {
        return false
    }

    _, ok = container_data.containerDef.storage.(ContainerGrid)
    if !ok {
        return false
    }

    if item.definition.width == item.definition.height {
        return false
    }

    return true
}

ContainerGridRotateItem :: proc(container: ^ItemInstance, item: ^ItemInstance) -> bool {
    if !ContainerGridCanRotateItem(container, item)
    {
        return false
    }

    item.rotated = !item.rotated
    if ContainerCanPlaceGrid(container, item) {
        return true
    }

    item.rotated = !item.rotated
    return false
}

ContainerGridMoveItem :: proc(
    container: ^ItemInstance,
    item:      ^ItemInstance,
    delta_x:   i16 = 0,
    delta_y:   i16 = 0) -> bool {
    if container == nil do return false

    container_data, ok := container.definition.data.(ContainerData)
    if !ok {
        return false
    }

    _, ok = container_data.containerDef.storage.(ContainerGrid)
    if !ok {
        return false
    }

    new_x := item.pos_x + delta_x
    new_y := item.pos_y + delta_y

    if !ContainerGridCanPlaceAt(container,
        item.definition,
        new_x,
        new_y,
        item.id,
    item.rotated,){
        return false
    }

    item.pos_x = new_x
    item.pos_y = new_y
    return true
}

ContainerGridPixelsXY :: proc(container: ^ItemInstance, cell_size: f32) -> rl.Vector2
{
    if container == nil do return {}

    container_data, ok := container.definition.data.(ContainerData)
    if !ok {
        return {}
    }

    grid, grid_ok := container_data.containerDef.storage.(ContainerGrid)
    if !grid_ok {
        return {}
    }

    size := rl.Vector2 {}
    size.x = cell_size * f32(grid.width)
    size.y = cell_size * f32(grid.height)

    return size
}