package inventory

ItemInstance :: struct{
    id: u64,
    definition: ^Item,
    rotated: bool,

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