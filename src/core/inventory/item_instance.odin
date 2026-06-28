package inventory

ItemInstance :: struct{
    id: u64,
    definition: ^Item,
    rotated: bool,
    grabbed: bool,

    pos_x, pos_y: i16,
}

ItemGetWidth :: proc(instance: ^ItemInstance) -> i16 {
    return instance.rotated ? instance.definition.height : instance.definition.width
}

ItemGetWidthRotated :: proc(def: ^Item, rotated: bool) -> i16 {
    return rotated ? def.height : def.width
}

ItemGetHeight :: proc(instance: ^ItemInstance) -> i16 {
    return instance.rotated ? instance.definition.width : instance.definition.height
}

ItemGetHeightRotated :: proc(def: ^Item, rotated: bool) -> i16 {
    return rotated ? def.width : def.height
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