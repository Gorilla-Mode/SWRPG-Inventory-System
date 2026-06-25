package app

import inv "../inventory"

State :: struct{
    InventoryGrid: string,
    grab:          Grab,
    ghost:         Ghost,
}

Grab :: struct{
    is_dragging: bool,
    dragged_item: ^inv.ItemInstance,
    offset_x: f32,
    offset_y: f32,
}

Ghost :: struct{
    pos_x: i16,
    pos_y: i16,
    rotated: bool,
    valid: bool,
}