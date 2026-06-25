package inventory

ItemInstance :: struct{
    id: u64,
    definition: ^Item,
    rotated: bool,
    grabbed: bool,

    pos_x, pos_y: i16,
}

ItemGetWidth :: proc(instance: ^ItemInstance) -> i16
{
    if instance.rotated {
        return instance.definition.height
    }
    return instance.definition.width
}

ItemGetHeight :: proc(instance: ^ItemInstance) -> i16
{
    if instance.rotated {
        return instance.definition.width
    }
    return instance.definition.height
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