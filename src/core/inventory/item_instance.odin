package inventory

ItemInstance :: struct{
    id: u64,
    definition: ^Item,
    data: InstanceData,
    rotated: bool,
    grabbed: bool,

    pos_x, pos_y: i16,
}

InstanceData :: union{
    WeaponInstanceData,
    ContainerInstanceData,
    ArmorInstanceData,
    GearInstanceData,
}

WeaponInstanceData :: struct{
    attachments: [dynamic]^ItemInstance,
}

ContainerInstanceData :: struct{
    items: [dynamic]^ItemInstance,
}

ArmorInstanceData :: struct{
    attachments: [dynamic]^ItemInstance,
}

GearInstanceData :: struct{
    attachments: [dynamic]^ItemInstance,
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