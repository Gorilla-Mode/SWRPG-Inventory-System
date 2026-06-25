package app

State :: struct{
    InventoryGrid: string,
    is_dragging: bool,
    grab_offset_x: f32,
    grab_offset_y: f32,
    ghost_pos_x: i16,
    ghost_pos_y: i16,
    ghost_rotated: bool,
    ghost_valid: bool,
}