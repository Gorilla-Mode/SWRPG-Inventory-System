package inventory

ItemInstance :: struct{
    id: u64,
    item: ^Item,

    pos_x, pos_y: i16,
}