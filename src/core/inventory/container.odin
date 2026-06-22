package inventory

ContainerType :: enum{
    Backpack,
    Belt,
    Clothing,
}

Container :: struct{
    id: string,
    width, height: i16,
    type: ContainerType,

    items: [dynamic]^ItemInstance
}

Rect :: struct {
    pos_x, pos_y: i16,
    width, height: i16,
}

ContainerCanPlace :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    item_bounds := GetBounds(item)

    if item_bounds.pos_x < 0 || item_bounds.pos_y < 0 {
        return false
    }

    if item_bounds.pos_x + item_bounds.width > container.width {
        return false
    }

    if item_bounds.pos_y + item_bounds.height > container.height {
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

    return ContainerCanPlace(container, &temp)
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

ContainerAddItem :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    if ContainerCanPlace(container, item) {
        append_elem(&container.items, item)
        return true
    }
    return false
}

ContainerRotateItem :: proc(container: ^Container, item: ^ItemInstance) -> bool {
    item.rotated = !item.rotated
    if ContainerCanPlace(container, item) {
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