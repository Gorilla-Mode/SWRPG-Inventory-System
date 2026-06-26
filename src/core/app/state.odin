package app

import inv "../inventory"

State :: struct{
    grab:          Grab,
    ghost:         Ghost,
}

Grab :: struct{
    is_dragging: bool,
    dragged_item: ^inv.ItemInstance,
    hovered_item: ^inv.ItemInstance,
    offset_x: f32,
    offset_y: f32,
}

Ghost :: struct{
    pos_x: i16,
    pos_y: i16,
    unsnapped_x: f32,
    unsnapped_y: f32,
    rotated: bool,
    valid: bool,
}