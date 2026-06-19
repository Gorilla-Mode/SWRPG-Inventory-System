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

ContainerCanPlace :: proc(container: ^Container, item: ^ItemInstance) -> bool{
    if item.pos_x < 0 || item.pos_y < 0 {
        return false
    }

    if item.pos_x + item.definition.width > container.width {
        return false
    }

    if item.pos_y + item.definition.height > container.height {
        return false
    }

    for existing in container.items{
        if existing.id == item.id {
            continue
        }

        if ContainerRectOverlap(item.pos_x,
        item.pos_y,
        item.definition.width,
        item.definition.height,
        existing.pos_x,
        existing.pos_y,
        existing.definition.width,
        existing.definition.height){
            return false
        }
    }
    return true
}

ContainerCanPlaceAt :: proc(container: ^Container,
    Item: ^Item,
    x: i16,
    y: i16,
    id: u64
) -> bool{
    temp_instance := new(ItemInstance)
    defer free(temp_instance)

    temp_instance.definition = Item
    temp_instance.pos_x      = x
    temp_instance.pos_y      = y
    temp_instance.id         = id

    return ContainerCanPlace(container, temp_instance)
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
        item.id) {
        return false
    }

    item.pos_x = new_x
    item.pos_y = new_y
    return true
}