package inventory

ItemInstance :: struct{
    id: u64,
    definition: ^Item,

    pos_x, pos_y: i16,
}