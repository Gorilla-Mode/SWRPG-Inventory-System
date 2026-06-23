package inventory

ContainerType :: enum{
    Backpack,
    Belt,
    Clothing,
}

Container :: struct{
    id: string,
    type: ContainerType,
    storage: ContainerStorage,

    items: [dynamic]^ItemInstance
}

ContainerStorage :: union{
    ContainerGrid,
    ContainerSlot,
    ContainerVolume
}

ContainerGrid :: struct {
    width, height: i16,
}

ContainerSlot :: struct {
    slots:          i32,
    occupied_slots: i32,
    item_whitelist: []string,
    tag_whitelist:  []ItemTag,
}

ContainerVolume :: struct {
    volume:      i32,
    volume_used: i32,

}

Rect :: struct {
    pos_x, pos_y: i16,
    width, height: i16,
}

// Dispatch function to determine if an item can be placed in a container, based on the container's storage type
ContainerCanPlace :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    switch _ in container.storage{
        case ContainerGrid:
            return ContainerCanPlaceGrid(container, item)
        case ContainerSlot:
            return ContainerCanPlaceSlot(container, item)
        case ContainerVolume:
            return ContainerCanPlaceVolume(container, item)
    }
    return false
}

ContainerCanPlaceSlot :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    slot, ok := container.storage.(ContainerSlot)
    if !ok {
        return false
    }

    if slot.slots <= slot.occupied_slots {
        return false
    }

    return true
}

ContainerCanPlaceVolume :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    vol, ok := container.storage.(ContainerVolume)
    if !ok {
        return false
    }

    if vol.volume_used + ItemArea(item.definition) > vol.volume {
        return false
    }
    return true
}



ContainerCanPlaceGrid :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    grid, ok := container.storage.(ContainerGrid)
    if !ok {
        return false
    }

    item_bounds := GetBounds(item)

    if item_bounds.pos_x < 0 || item_bounds.pos_y < 0 {
        return false
    }

    if item_bounds.pos_x + item_bounds.width > grid.width {
        return false
    }

    if item_bounds.pos_y + item_bounds.height > grid.height {
        return false
    }

    for existing in container.items{
        if existing.id == item.id {
            continue
        }
        existing_item_bounds := GetBounds(existing)
        if ContainerRectOverlap( existing_item_bounds.pos_x,
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

ContainerCanPlaceAt :: proc(container: ^Container,
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

ContainerRectOverlap :: proc(
    ax, ay, aw, ah: i16,
    bx, by, bw, bh: i16,
) -> bool {
    return !(ax + aw <= bx ||
        bx + bw <= ax ||
        ay + ah <= by ||
        by + bh <= ay)
}

//TODO: Implement the other container types
ContainerAddItem :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    if ContainerCanPlaceGrid(container, item) {
        append_elem(&container.items, item)
        return true
    }
    return false
}

ContainerRotateItem :: proc(container: ^Container, item: ^ItemInstance) -> bool {
    item.rotated = !item.rotated
    if ContainerCanPlaceGrid(container, item) {
        return true
    }
    item.rotated = !item.rotated
    return false
}

ContainerMovieItem :: proc(
    container: ^Container,
    item: ^ItemInstance,
    delta_x: i16 = 0,
    delta_y: i16 = 0
) -> bool {
    new_x := item.pos_x + delta_x
    new_y := item.pos_y + delta_y

    if !ContainerCanPlaceAt(container,
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

GetBounds :: proc(item: ^ItemInstance) -> Rect {
    if item.rotated {
        return Rect{
            pos_x = item.pos_x,
            pos_y = item.pos_y,
            width = item.definition.height,
            height = item.definition.width,
        }
    }

    return Rect{
        pos_x = item.pos_x,
        pos_y = item.pos_y,
        width = item.definition.width,
        height = item.definition.height,
    }
}